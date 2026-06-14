import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/models/response/my_single_card_purchase_response.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/app_state.dart';
import '../../home/providers/theme_provider.dart';

class MySingleCardsScreen extends StatefulWidget {
  const MySingleCardsScreen({super.key});

  @override
  State<MySingleCardsScreen> createState() => _MySingleCardsScreenState();
}

class _MySingleCardsScreenState extends State<MySingleCardsScreen> {
  bool _savingQr = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadMySingleCards(refresh: true);
    });
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _saveQrToGallery(String? qrImageUrl) async {
    if (_savingQr) return;

    if (qrImageUrl == null || qrImageUrl.isEmpty) {
      _showToast('QR image is not available', isError: true);
      return;
    }

    setState(() {
      _savingQr = true;
    });

    try {
      final hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        final granted = await Gal.requestAccess();

        if (!granted) {
          _showToast('Storage permission denied', isError: true);
          return;
        }
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'chemistry_ar_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';

      await Dio().download(qrImageUrl, filePath);

      final file = File(filePath);
      if (!await file.exists()) {
        _showToast('Download QR failed', isError: true);
        return;
      }

      await Gal.putImage(filePath);

      _showToast('QR saved to gallery');
    } catch (e) {
      debugPrint('Save QR error: $e');
      _showToast('Save QR failed', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _savingQr = false;
        });
      }
    }
  }

  void _showQrDialog(MySingleCardPurchaseResponse card) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.35),
          ),
        ),
        title: Text(
          card.singleCardName ?? 'AR Card',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (card.qrImageUrl != null && card.qrImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  card.qrImageUrl!,
                  width: 230,
                  height: 230,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _QrFallbackBox(
                    text: 'Cannot load QR image',
                  ),
                ),
              )
            else
              const _QrFallbackBox(
                text: 'QR image is not available',
              ),
            const SizedBox(height: 14),
            Text(
              'QR Content: ${card.qrContent ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _savingQr
                ? null
                : () => _saveQrToGallery(card.qrImageUrl),
            icon: _savingQr
                ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.download),
            label: const Text('Save QR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    await context.read<AppState>().loadMySingleCards(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final state = context.watch<AppState>();
    final cards = state.mySingleCards;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: _buildBody(state, cards),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'My AR Cards',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.35),
              ),
            ),
            child: Icon(
              Icons.qr_code_2_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      AppState state,
      List<MySingleCardPurchaseResponse> cards,
      ) {
    if (state.loadingMySingleCards && cards.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (cards.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 24),
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary.withOpacity(0.8),
            size: 64,
          ),
          const SizedBox(height: 18),
          Text(
            'Bạn chưa mua card AR lẻ nào.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Các card AR lẻ đã mua sẽ xuất hiện tại đây để bạn xem hạn dùng và tải lại QR.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: cards.length + (state.mySingleCardsLast ? 0 : 1),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= cards.length) {
          return _LoadMoreButton(
            loading: state.loadingMySingleCards,
            onTap: () => state.loadMySingleCards(),
          );
        }

        final card = cards[index];

        return _MySingleCardTile(
          card: card,
          onShowQr: () => _showQrDialog(card),
        );
      },
    );
  }
}

class _MySingleCardTile extends StatelessWidget {
  final MySingleCardPurchaseResponse card;
  final VoidCallback onShowQr;

  const _MySingleCardTile({
    required this.card,
    required this.onShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final active = card.active;

    final expiredText = card.expiredAt == null
        ? 'Không rõ hạn'
        : DateFormat('dd/MM/yyyy HH:mm').format(card.expiredAt!);

    final formula = card.substanceFormula ?? '?';
    final name = card.substanceVietnameseName != null &&
        card.substanceVietnameseName!.isNotEmpty
        ? card.substanceVietnameseName!
        : card.substanceName ?? card.singleCardName ?? 'AR Card';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.error.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: active
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.error.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: active
                  ? AppColors.cyanEmeraldGradient
                  : LinearGradient(
                colors: [
                  AppColors.textSecondary.withOpacity(0.35),
                  AppColors.textSecondary.withOpacity(0.18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? AppColors.primary.withOpacity(0.25)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Center(
              child: Text(
                formula,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  card.singleCardName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.secondary.withOpacity(0.14)
                            : AppColors.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? AppColors.secondary.withOpacity(0.35)
                              : AppColors.error.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        active ? 'Còn hạn' : 'Đã hết hạn',
                        style: TextStyle(
                          color: active
                              ? AppColors.emphasisPositive
                              : AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  active ? 'Đến $expiredText' : 'Hết hạn: $expiredText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onShowQr,
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.35),
                ),
              ),
              child: Icon(
                Icons.qr_code_2,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrFallbackBox extends StatelessWidget {
  final String text;

  const _QrFallbackBox({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 230,
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.4),
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _LoadMoreButton({
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.35),
          ),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(
            'Load more',
            style: TextStyle(
              color: AppColors.accentText,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}