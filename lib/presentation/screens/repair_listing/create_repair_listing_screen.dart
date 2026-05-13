import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../logic/repair_listing/create_repair_listing_bloc.dart';
import '../../../logic/repair_listing/create_repair_listing_event.dart';
import '../../../logic/repair_listing/create_repair_listing_state.dart';
import '../../../data/models/brand_model.dart';
import '../../../data/models/device_model.dart';

class CreateRepairListingScreen extends StatefulWidget {
  const CreateRepairListingScreen({super.key});

  @override
  State<CreateRepairListingScreen> createState() => _CreateRepairListingScreenState();
}

class _CreateRepairListingScreenState extends State<CreateRepairListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CreateRepairListingBloc>().add(LoadCreateRepairListingData());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (pickedFile != null && mounted) {
      context.read<CreateRepairListingBloc>().add(AddRepairImage(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tamir İlanı Oluştur'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<CreateRepairListingBloc, CreateRepairListingState>(
        listener: (context, state) {
          if (state is CreateRepairListingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is CreateRepairListingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('İlan başarıyla oluşturuldu'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          }
        },
        buildWhen: (previous, current) {
          return current is! CreateRepairListingSubmitting;
        },
        builder: (context, state) {
          if (state is CreateRepairListingLoadingData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CreateRepairListingDataLoaded) {
            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Cihaz Bilgileri'),
                          const SizedBox(height: 12),
                          _buildBrandDropdown(state),
                          const SizedBox(height: 12),
                          _buildModelDropdown(state),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle('İlan Bilgileri'),
                          const SizedBox(height: 12),
                          _buildPhoneField(state),
                          const SizedBox(height: 12),
                          _buildTitleField(state),
                          const SizedBox(height: 12),
                          _buildDescriptionField(state),
                          
                          const SizedBox(height: 24),
                          _buildSectionTitle('Görseller (En fazla 3)'),
                          const SizedBox(height: 12),
                          _buildImagePicker(state),
                          
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            );
          }

          return const Center(child: Text('Bir hata oluştu'));
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBrandDropdown(CreateRepairListingDataLoaded state) {
    return DropdownButtonFormField<BrandModel>(
      key: ValueKey('brand_${state.selectedBrand?.id ?? 'none'}'),
      initialValue: state.selectedBrand,
      decoration: InputDecoration(
        labelText: 'Marka',
        prefixIcon: const Icon(Icons.phone_android),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      menuMaxHeight: 300,
      isExpanded: true,
      items: state.brands.map((brand) {
        return DropdownMenuItem(
          value: brand,
          child: Text(
            brand.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<CreateRepairListingBloc>().add(SelectRepairBrand(value));
        }
      },
      validator: (value) => value == null ? 'Lütfen marka seçiniz' : null,
    );
  }

  Widget _buildModelDropdown(CreateRepairListingDataLoaded state) {
    final hasModels = state.models?.isNotEmpty ?? false;
    
    return DropdownButtonFormField<DeviceModel>(
      key: ValueKey('model_${state.selectedModel?.id ?? 'none'}'),
      initialValue: state.selectedModel,
      decoration: InputDecoration(
        labelText: 'Model',
        prefixIcon: const Icon(Icons.devices),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      menuMaxHeight: 300,
      isExpanded: true,
      items: hasModels ? state.models!.map((model) {
        return DropdownMenuItem(
          value: model,
          child: Text(
            model.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList() : null,
      onChanged: hasModels ? (value) {
        if (value != null) {
          context.read<CreateRepairListingBloc>().add(SelectRepairModel(value));
        }
      } : null,
      validator: (value) => value == null ? 'Lütfen model seçiniz' : null,
    );
  }

  Widget _buildPhoneField(CreateRepairListingDataLoaded state) {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Telefon Numarası',
        prefixIcon: const Icon(Icons.phone),
        hintText: '5XX XXX XX XX',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: (value) {
        context.read<CreateRepairListingBloc>().add(UpdateRepairPhone(value));
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Telefon numarası gerekli';
        if (value.length != 10) return 'Geçerli bir telefon numarası giriniz';
        return null;
      },
    );
  }

  Widget _buildTitleField(CreateRepairListingDataLoaded state) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'İlan Başlığı',
        prefixIcon: const Icon(Icons.title),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      onChanged: (value) {
        context.read<CreateRepairListingBloc>().add(UpdateRepairTitle(value));
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Başlık gerekli';
        if (value.length < 10) return 'Başlık en az 10 karakter olmalı';
        return null;
      },
    );
  }

  Widget _buildDescriptionField(CreateRepairListingDataLoaded state) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Açıklama',
        prefixIcon: const Icon(Icons.description),
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
      maxLines: 5,
      maxLength: 500,
      onChanged: (value) {
        context.read<CreateRepairListingBloc>().add(UpdateRepairDescription(value));
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Açıklama gerekli';
        if (value.length < 20) return 'Açıklama en az 20 karakter olmalı';
        return null;
      },
    );
  }

  Widget _buildImagePicker(CreateRepairListingDataLoaded state) {
    return Column(
      children: [
        if (state.selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(state.selectedImages[index])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          context.read<CreateRepairListingBloc>().add(
                            RemoveRepairImage(state.selectedImages[index]),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        
        if (state.selectedImages.length < 3)
          const SizedBox(height: 12),
        
        if (state.selectedImages.length < 3)
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(
              state.selectedImages.isEmpty 
                  ? 'Görsel Ekle (Zorunlu)' 
                  : 'Görsel Ekle (${state.selectedImages.length}/3)',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BlocBuilder<CreateRepairListingBloc, CreateRepairListingState>(
      builder: (context, state) {
        final isSubmitting = state is CreateRepairListingSubmitting;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: isSubmitting ? null : () {
                if (_formKey.currentState!.validate()) {
                  context.read<CreateRepairListingBloc>().add(SubmitRepairListing());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'İlanı Yayınla',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}