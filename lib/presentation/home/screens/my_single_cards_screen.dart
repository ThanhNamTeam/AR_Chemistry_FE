import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context);

    if (qrImageUrl == null || qrImageUrl.isEmpty) {
      _showToast(l10n.qrImageNotAvailable, isError: true);
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
          _showToast(l10n.storagePermissionDenied, isError: true);
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
        _showToast(l10n.downloadQrFailed, isError: true);
        return;
      }

      await Gal.putImage(filePath);

      _showToast(l10n.qrSavedToGallery);
    } catch (e) {
      debugPrint('Save QR error: $e');
      _showToast(l10n.saveQrFailed, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _savingQr = false;
        });
      }
    }
  }

  void _showQrDialog(MySingleCardPurchaseResponse card) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
        title: Text(
          card.singleCardName ?? l10n.arCard,
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
                  errorBuilder: (_, _, _) => _QrFallbackBox(
                    text: l10n.cannotLoadQrImage,
                  ),
                ),
              )
            else
              _QrFallbackBox(
                text: l10n.qrImageNotAvailable,
              ),
            const SizedBox(height: 14),
            Text(
              '${l10n.qrContentLabel}${card.qrContent ?? ''}',
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
            label: Text(l10n.saveQr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
              l10n.myArCards,
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
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.35),
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
    final l10n = AppLocalizations.of(context);
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
            color: AppColors.primary.withValues(alpha: 0.8),
            size: 64,
          ),
          const SizedBox(height: 18),
          Text(
            l10n.noSingleArCardsPurchased,
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
            l10n.singleArCardsEmptyHint,
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
      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
    final l10n = AppLocalizations.of(context);
    final active = card.active;

    final expiredText = card.expiredAt == null
        ? l10n.expiryUnknown
        : DateFormat('dd/MM/yyyy HH:mm').format(card.expiredAt!);

    final formula = card.substanceFormula ?? '?';
    final name = card.substanceVietnameseName != null &&
        card.substanceVietnameseName!.isNotEmpty
        ? card.substanceVietnameseName!
        : card.substanceName ?? card.singleCardName ?? l10n.arCard;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.error.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: active
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.error.withValues(alpha: 0.06),
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
                  AppColors.textSecondary.withValues(alpha: 0.35),
                  AppColors.textSecondary.withValues(alpha: 0.18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.08),
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
                            ? AppColors.secondary.withValues(alpha: 0.14)
                            : AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? AppColors.secondary.withValues(alpha: 0.35)
                              : AppColors.error.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        active ? l10n.stillActive : l10n.expired,
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
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
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
          color: AppColors.cardBorder.withValues(alpha: 0.4),
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
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
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
            l10n.loadMore,
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