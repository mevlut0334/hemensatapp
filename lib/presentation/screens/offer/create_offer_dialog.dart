// lib/presentation/screens/offer/create_offer_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/service_locator.dart';
import '../../../logic/offer/offer_bloc.dart';
import '../../../logic/offer/offer_event.dart';
import '../../../logic/offer/offer_state.dart';
import '../../../data/models/offer_model.dart';

class CreateOfferDialog extends StatefulWidget {
  final int listingId;
  final String listingType; // 'RepairListing' veya 'SaleListing'
  final String listingTitle;

  const CreateOfferDialog({
    super.key,
    required this.listingId,
    required this.listingType,
    required this.listingTitle,
  });

  @override
  State<CreateOfferDialog> createState() => _CreateOfferDialogState();

  /// Tamir ilanı için dialog aç
  static Future<bool?> showForRepairListing({
    required BuildContext context,
    required int listingId,
    required String listingTitle,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<OfferBloc>(),
        child: CreateOfferDialog(
          listingId: listingId,
          listingType: 'RepairListing',
          listingTitle: listingTitle,
        ),
      ),
    );
  }

  /// Satış ilanı için dialog aç
  static Future<bool?> showForSaleListing({
    required BuildContext context,
    required int listingId,
    required String listingTitle,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<OfferBloc>(),
        child: CreateOfferDialog(
          listingId: listingId,
          listingType: 'SaleListing',
          listingTitle: listingTitle,
        ),
      ),
    );
  }
}

class _CreateOfferDialogState extends State<CreateOfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController(); // ✅ Eklendi
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _phoneController.dispose(); // ✅ Eklendi
    super.dispose();
  }

  void _submitOffer() {
    if (_formKey.currentState!.validate()) {
      final price = double.parse(_priceController.text.replaceAll(',', '.'));
      final phone = _phoneController.text.trim(); // ✅ Eklendi

      final request = CreateOfferRequest(
        offerPrice: price,
        phoneNumber: phone, // ✅ Eklendi
        offerableType: 'App\\Models\\${widget.listingType}',
        offerableId: widget.listingId,
      );

      context.read<OfferBloc>().add(CreateOfferEvent(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OfferBloc, OfferState>(
      listener: (context, state) {
        if (state is OfferLoading) {
          setState(() => _isSubmitting = true);
        } else {
          setState(() => _isSubmitting = false);
        }

        if (state is OfferCreated) {
          Navigator.of(context).pop(true); // Dialog'u kapat ve başarı döndür
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is OfferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView( // ✅ ScrollView eklendi (klavye için)
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Row(
                    children: [
                      const Icon(
                        Icons.local_offer,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Teklif Ver',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // İlan başlığı
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_android,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.listingTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fiyat girişi
                  const Text(
                    'Teklif Fiyatı',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Örn: 1500',
                      prefixIcon: const Icon(Icons.attach_money, color: AppColors.primary),
                      suffixText: '₺',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir fiyat girin';
                      }
                      final price = double.tryParse(value.replaceAll(',', '.'));
                      if (price == null) {
                        return 'Geçerli bir fiyat girin';
                      }
                      if (price <= 0) {
                        return 'Fiyat 0\'dan büyük olmalıdır';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16), // ✅ Boşluk azaltıldı

                  // ✅ Telefon numarası girişi (YENİ)
                  const Text(
                    'İletişim Telefonu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    decoration: InputDecoration(
                      hintText: '05xxxxxxxxx',
                      prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen telefon numaranızı girin';
                      }
                      if (value.length < 10) {
                        return 'Telefon numarası en az 10 haneli olmalıdır';
                      }
                      if (!RegExp(r'^0[0-9]{9,10}$').hasMatch(value)) {
                        return 'Geçerli bir telefon numarası girin (0 ile başlamalı)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Butonlar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'İptal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitOffer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Gönder',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}