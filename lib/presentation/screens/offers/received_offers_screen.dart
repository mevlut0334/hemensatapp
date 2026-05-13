// lib/presentation/screens/offer/received_offers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/service_locator.dart';
import '../../../logic/offer/offer_bloc.dart';
import '../../../logic/offer/offer_event.dart';
import '../../../logic/offer/offer_state.dart';
import '../../../data/models/offer_model.dart';

class ReceivedOffersScreen extends StatelessWidget {
  const ReceivedOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OfferBloc>()..add(const LoadMyReceivedOffersEvent()),
      child: const _ReceivedOffersView(),
    );
  }
}

class _ReceivedOffersView extends StatelessWidget {
  const _ReceivedOffersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gelen Tekliflerim'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<OfferBloc, OfferState>(
        listener: (context, state) {
          if (state is OfferAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            context.read<OfferBloc>().add(const LoadMyReceivedOffersEvent());
          } else if (state is OfferRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
            context.read<OfferBloc>().add(const LoadMyReceivedOffersEvent());
          } else if (state is OfferError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OfferLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is OfferError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<OfferBloc>().add(const LoadMyReceivedOffersEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is MyReceivedOffersLoaded) {
            if (state.offers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz gelen teklifiniz yok',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<OfferBloc>().add(const LoadMyReceivedOffersEvent());
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.offers.length,
                itemBuilder: (context, index) {
                  final offer = state.offers[index];
                  return _OfferCard(offer: offer);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferModel offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final isPending = offer.isPending;
    final isAccepted = offer.isAccepted;
    final isRejected = offer.isRejected;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İlan Bilgisi
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    offer.listing.isRepairListing
                        ? Icons.build_outlined
                        : Icons.phone_android,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.listing.isRepairListing
                            ? 'Tamir İlanı'
                            : 'Satış İlanı',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Kullanıcı
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  offer.phoneNumber ?? 'Telefon numarası yok',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Teklif Fiyatı
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${offer.offerPrice.toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tarih
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(offer.submittedAt),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            _buildStatusBadge(isPending, isAccepted, isRejected),

            // --- Kabul / Reddet Butonları (yorum satırına alındı) ---
            /*
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showRejectConfirmDialog(context, offer.id);
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reddet'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAcceptConfirmDialog(context, offer.id);
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Kabul Et'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            */
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Dün ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildStatusBadge(bool isPending, bool isAccepted, bool isRejected) {
    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    if (isAccepted) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      text = 'Kabul Edildi';
      icon = Icons.check_circle;
    } else if (isRejected) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      text = 'Reddedildi';
      icon = Icons.cancel;
    } else {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      text = 'Beklemede';
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog metodları da yorum satırına alınabilir (isteğe bağlı)
  /*
  void _showAcceptConfirmDialog(BuildContext context, int offerId) { ... }

  void _showRejectConfirmDialog(BuildContext context, int offerId) { ... }
  */
}
