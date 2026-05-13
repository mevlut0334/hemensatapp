// lib/presentation/screens/home/sale_listing_filter_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../logic/sale_listing/sale_listings_list_bloc.dart';
import '../../../logic/sale_listing/sale_listings_list_event.dart';
import '../../../logic/sale_listing/sale_listings_list_state.dart';
import '../../../logic/location/location_cubit.dart';
import '../../../logic/location/location_state.dart';
import '../../../data/repositories/sale_listing_repository.dart';
import '../../../core/service_locator.dart';
import '../../../data/models/brand_model.dart';
import '../../../data/models/device_model.dart';

class SaleListingFilterDialog extends StatefulWidget {
  const SaleListingFilterDialog({super.key});

  @override
  State<SaleListingFilterDialog> createState() => _SaleListingFilterDialogState();
}

class _SaleListingFilterDialogState extends State<SaleListingFilterDialog> {
  final _saleListingRepository = sl<SaleListingRepository>();
  
  List<BrandModel> _brands = [];
  List<DeviceModel> _models = [];

  bool _isLoadingBrands = false;
  bool _isLoadingModels = false;

  int? _selectedBrandId;
  int? _selectedModelId;
  int? _selectedProvinceId;
  int? _selectedDistrictId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Mevcut filtreleri al
    final currentState = context.read<SaleListingsListBloc>().state;
    if (currentState is SaleListingsListLoaded) {
      _selectedBrandId = currentState.filteredBrandId;
      _selectedModelId = currentState.filteredModelId;
      _selectedProvinceId = currentState.filteredProvinceId;
      _selectedDistrictId = currentState.filteredDistrictId;
    }

    // Markaları yükle
    await _loadBrands();

    // Eğer marka seçiliyse modelleri yükle
    if (_selectedBrandId != null) {
      await _loadModels(_selectedBrandId!);
    }

    // Lokasyon verilerini yükle
    if (mounted) {
      context.read<LocationCubit>().fetchProvinces();
      
      // Eğer il seçiliyse ilçeleri yükle
      if (_selectedProvinceId != null) {
        context.read<LocationCubit>().fetchDistricts(_selectedProvinceId!);
      }
    }
  }

  Future<void> _loadBrands() async {
    setState(() => _isLoadingBrands = true);
    try {
      final brands = await _saleListingRepository.getBrands();
      setState(() {
        _brands = brands;
        _isLoadingBrands = false;
      });
    } catch (e) {
      setState(() => _isLoadingBrands = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Markalar yüklenemedi: $e')),
        );
      }
    }
  }

  Future<void> _loadModels(int brandId) async {
    setState(() {
      _isLoadingModels = true;
      _models = [];
      _selectedModelId = null;
    });

    try {
      final models = await _saleListingRepository.getModelsByBrand(brandId);
      setState(() {
        _models = models;
        _isLoadingModels = false;
      });
    } catch (e) {
      setState(() => _isLoadingModels = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Modeller yüklenemedi: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    context.read<SaleListingsListBloc>().add(
          FilterSaleListings(
            brandId: _selectedBrandId,
            modelId: _selectedModelId,
            provinceId: _selectedProvinceId,
            districtId: _selectedDistrictId,
          ),
        );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedBrandId = null;
      _selectedModelId = null;
      _selectedProvinceId = null;
      _selectedDistrictId = null;
      _models = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Filtrele',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Marka Dropdown
                    _buildSectionTitle('Marka'),
                    const SizedBox(height: 8),
                    _buildBrandDropdown(),
                    
                    const SizedBox(height: 16),
                    
                    // Model Dropdown
                    _buildSectionTitle('Model'),
                    const SizedBox(height: 8),
                    _buildModelDropdown(),
                    
                    const SizedBox(height: 16),
                    
                    // İl Dropdown
                    _buildSectionTitle('İl'),
                    const SizedBox(height: 8),
                    _buildProvinceDropdown(),
                    
                    const SizedBox(height: 16),
                    
                    // İlçe Dropdown
                    _buildSectionTitle('İlçe'),
                    const SizedBox(height: 8),
                    _buildDistrictDropdown(),
                  ],
                ),
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text(
                        'Temizle',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Uygula'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildBrandDropdown() {
    if (_isLoadingBrands) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int>(
      initialValue: _selectedBrandId,
      decoration: InputDecoration(
        hintText: 'Marka Seçin',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: _brands.map((brand) {
        return DropdownMenuItem<int>(
          value: brand.id,
          child: Text(brand.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBrandId = value;
          _selectedModelId = null;
          _models = [];
        });
        if (value != null) {
          _loadModels(value);
        }
      },
    );
  }

  Widget _buildModelDropdown() {
    if (_isLoadingModels) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int>(
      initialValue: _selectedModelId,
      decoration: InputDecoration(
        hintText: _selectedBrandId == null ? 'Önce marka seçin' : 'Model Seçin',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: _models.map((model) {
        return DropdownMenuItem<int>(
          value: model.id,
          child: Text(model.name),
        );
      }).toList(),
      onChanged: _selectedBrandId == null
          ? null
          : (value) {
              setState(() {
                _selectedModelId = value;
              });
            },
    );
  }

  Widget _buildProvinceDropdown() {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state.isLoading && state.provinces.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return DropdownButtonFormField<int>(
          initialValue: _selectedProvinceId,
          decoration: InputDecoration(
            hintText: 'İl Seçin',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: state.provinces.map((province) {
            return DropdownMenuItem<int>(
              value: province.id,
              child: Text(province.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProvinceId = value;
              _selectedDistrictId = null;
            });
            if (value != null) {
              context.read<LocationCubit>().fetchDistricts(value);
            }
          },
        );
      },
    );
  }

  Widget _buildDistrictDropdown() {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state.isLoading && state.districts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return DropdownButtonFormField<int>(
          initialValue: _selectedDistrictId,
          decoration: InputDecoration(
            hintText: _selectedProvinceId == null ? 'Önce il seçin' : 'İlçe Seçin',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: state.districts.map((district) {
            return DropdownMenuItem<int>(
              value: district.id,
              child: Text(district.name),
            );
          }).toList(),
          onChanged: _selectedProvinceId == null
              ? null
              : (value) {
                  setState(() {
                    _selectedDistrictId = value;
                  });
                },
        );
      },
    );
  }
}