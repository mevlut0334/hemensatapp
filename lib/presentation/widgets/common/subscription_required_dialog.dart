// lib/presentation/widgets/common/subscription_required_dialog.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SubscriptionRequiredDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onSubscribePressed;

  const SubscriptionRequiredDialog({
    super.key,
    required this.message,
    this.onSubscribePressed,
  });

  /// Detay görüntüleme için dialog göster
  static Future<void> showForDetails(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SubscriptionRequiredDialog(
        message: 'İlan detaylarını görmek için abone olmalısınız.',
        onSubscribePressed: () {
          Navigator.of(context).pop();
          
          // Navigator.pushNamed(context, '/subscription');
        },
      ),
    );
  }

  /// Teklif verme için dialog göster
  static Future<void> showForOffer(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => SubscriptionRequiredDialog(
        message: 'Teklif verebilmek için abone olmalısınız.',
        onSubscribePressed: () {
          Navigator.of(context).pop();
          
          // Navigator.pushNamed(context, '/subscription');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Abonelik Gerekli',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'İptal',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onSubscribePressed ?? () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Abone Ol'),
        ),
      ],
    );
  }
}