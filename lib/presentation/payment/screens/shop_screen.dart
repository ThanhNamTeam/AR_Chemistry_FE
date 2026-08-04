import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/models/response/card_bundle_response.dart';
import '../../../core/models/response/single_card_purchase_response.dart';
import '../../../core/models/response/single_card_shop_response.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../shared/widgets/flash_card_flip_view.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../home/providers/theme_provider.dart';
import '../../../domain/models/chemical_card_model.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/app_localizations.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _showQRModal = false;
  String? _selectedId;
  int _selectedPrice = 0;
  String _selectedType = 'card';
  String? _proofImageUrl;
  String? _transferCode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();

      state.refreshKnowledgePoints();
      state.loadShopSingleCards(refresh: true);
      state.loadMySingleCards(refresh: true);
      state.loadShopCardBundles(refresh: true);
    });
  }

  Future<void> _saveQrToGallery(String? qrImageUrl) async {
    final l10n = AppLocalizations.of(context);
    if (qrImageUrl == null || qrImageUrl.isEmpty) {
      _showToast(l10n.qrImageNotAvailable, isError: true);
      return;
    }

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

      await Gal.putImage(filePath);

      _showToast(l10n.qrSavedToGallery);
    } catch (e) {
      debugPrint('Save QR error: $e');
      _showToast(l10n.saveQrFailed, isError: true);
    }
  }

  void _showPurchasedQrDialog(SingleCardPurchaseResponse purchase) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        // cardBg + textPrimary theo theme — Colors.white tàng hình trên Light.
        backgroundColor: AppColors.cardBg,
        title: Text(
          purchase.singleCardName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (purchase.qrImageUrl != null && purchase.qrImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  purchase.qrImageUrl!,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              )
            else
              Text(
                l10n.qrImageNotAvailable,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${l10n.qrContentLabel}${purchase.qrContent}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              purchase.expiredAt == null
                  ? ''
                  : '${l10n.expiresAtLabel}${DateFormat('dd/MM/yyyy HH:mm').format(purchase.expiredAt!)}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _saveQrToGallery(purchase.qrImageUrl),
            child: Text(l10n.saveQr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _fakeBuySingleCard(
    AppState state,
    String singleCardId, {
    required String cardName,
    required int kpPrice,
  }) async {
    final l10nConfirm = AppLocalizations.of(context);
    // Trừ KP là không hoàn tác được — xác nhận trước, nêu rõ giá.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(
          cardName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          l10nConfirm.buyConfirmMessage(kpPrice),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10nConfirm.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10nConfirm.buyConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final purchase = await state.fakeBuySingleCard(singleCardId);

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    if (purchase == null) {
      _showToast(l10n.buySingleCardFailed, isError: true);
      return;
    }

    await state.refreshKnowledgePoints();
    await state.loadMySingleCards(refresh: true);
    await state.loadShopSingleCards(refresh: true);

    if (!mounted) return;

    _showToast(l10n.cardPurchasedSuccess);
    _showPurchasedQrDialog(purchase);
  }

  Future<void> _buyWithPoints(
      AppState state, String id, int price, String type) async {
    final l10n = AppLocalizations.of(context);
    if (state.knowledgePoints < price) {
      _showToast(l10n.notEnoughKnowledgePoints, isError: true);
      return;
    }

    final ok = type == 'CHEMICAL_CARD'
        ? await state.purchaseCard(id)
        : await state.purchaseBundle(id);

    if (!mounted) return;

    if (ok) {
      _showToast(type == 'CHEMICAL_CARD'
          ? l10n.cardPurchasedCheckBag
          : l10n.bundleAddedToBag);
    } else {
      _showToast(l10n.notEnoughKnowledgePoints, isError: true);
    }
  }

  Future<void> _pickProofImage(AppState state) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final fileSize = bytes.length;
    final fileName = picked.name;

    final lowerName = fileName.toLowerCase();
    final contentType = lowerName.endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';

    final fileUrl = await state.uploadPaymentProof(
      fileName: fileName,
      contentType: contentType,
      fileSize: fileSize,
      bytes: bytes,
    );

    if (!mounted) return;

    if (fileUrl == null) {
      _showToast(AppLocalizations.of(context).uploadProofImageFailed, isError: true);
      return;
    }

    setState(() {
      _proofImageUrl = fileUrl;
    });

    _showToast(AppLocalizations.of(context).proofImageUploadedSuccess);
  }

  void _openQR(String id, int price, String type) {
    setState(() {
      _selectedId = id;
      _selectedPrice = price;
      _selectedType = type;
      _proofImageUrl = null;
      _transferCode = 'CHEM_${DateTime.now().millisecondsSinceEpoch}';
      _showQRModal = true;
    });
  }

  Future<void> _confirmQRPayment(AppState state) async {
    if (_selectedId == null) return;

    if (_proofImageUrl == null || _proofImageUrl!.isEmpty) {
      _showToast(AppLocalizations.of(context).uploadPaymentProofFirst, isError: true);
      return;
    }

    final ok = await state.createBankPayment(
      itemId: _selectedId!,
      itemType: _selectedType,
      proofImageUrl: _proofImageUrl!,
    );

    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    if (!ok) {
      _showToast(l10n.createPaymentFailed, isError: true);
      return;
    }

    setState(() => _showQRModal = false);

    _showToast(l10n.paymentSubmittedWaitApproval);

    Navigator.pushNamed(context, AppRoutes.paymentSuccess);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final singleCards = state.shopSingleCards;
    final bundles = state.shopCardBundles;



    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        // Không có nút quay lại: Cửa hàng là một đích của thanh
                        // nav dưới, người dùng chuyển trang bằng thanh đó.
                        // Back cứng của Android / vuốt mép trên iOS vẫn hoạt
                        // động bình thường vì route này vẫn được push.
                        Expanded(
                          child: Text(
                            l10n.shop,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Thư viện đã được gộp vào Cửa hàng: bỏ khỏi thanh nav
                        // dưới (nhường chỗ cho Trang chủ) nên phải có lối vào
                        // rõ ràng ngay tại đây.
                        Semantics(
                          button: true,
                          label: l10n.myLibrary,
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.library),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.menu_book_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Icon(Icons.shopping_cart_outlined,
                                    color: AppColors.primary, size: 20),
                              ),
                              if (state.cart.isNotEmpty)
                                Positioned(
                                  top: 2, right: 2,
                                  child: Container(
                                    width: 16, height: 16,
                                    decoration: BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('${state.cart.length}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        KnowledgePointsBadge(points: state.knowledgePoints),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bundle section
                          Row(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.bundlePacks,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      fontFamily: 'Inter')),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.secondary.withOpacity(0.4)),
                                ),
                                child: Text(l10n.upTo20PercentOff,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.emphasisPositive,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          if (state.loadingShopCardBundles)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else ...[
                            const SizedBox(height: 14),
                            ...bundles.map((b) {
                              final canPurchase = b.purchasable;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _BundleCard(
                                  bundle: b,
                                  isOwned: state.isCardOwned,
                                  onBuyPoints: canPurchase
                                      ? () => _buyWithPoints(
                                    state,
                                    b.id,
                                    b.discountedPrice,
                                    'CARD_BUNDLE',
                                  )
                                      : null,
                                  onBuyBank: canPurchase
                                      ? () => _openQR(
                                    b.id,
                                    b.discountedPrice,
                                    'CARD_BUNDLE',
                                  )
                                      : null,
                                  onAddToCart: canPurchase && !state.isBundleInCart(b.id)
                                      ? () async {
                                    final ok = await state.addBundleToCart(b.id);
                                    if (ok) {
                                      _showToast(l10n.bundleAddedToCart);
                                    }
                                  }
                                      : null,
                                ),
                              );
                            }),
                          ],

                          const SizedBox(height: 8),
                          Text(
                            l10n.singleCards,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (state.loadingShopSingleCards)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: singleCards.length,
                              itemBuilder: (ctx, i) {
                                final card = singleCards[i];
                                final owned = state.isSingleCardOwned(card.id);

                                return _SingleCardShopTile(
                                  card: card,
                                  owned: owned,
                                  onBuy: owned
                                      ? null
                                      : () => _fakeBuySingleCard(
                                            state,
                                            card.id,
                                            cardName: card.name,
                                            kpPrice: card.kpPrice,
                                          ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // QR Modal
              if (_showQRModal)
                _QRModal(
                  price: _selectedPrice,
                  transferCode: _transferCode ?? '',
                  proofImageUrl: _proofImageUrl,
                  onPickProof: () => _pickProofImage(state),
                  onConfirm: () => _confirmQRPayment(state),
                  onCancel: () => setState(() => _showQRModal = false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  final CardBundleResponse bundle;
  final bool Function(String id) isOwned;
  final VoidCallback? onBuyPoints;
  final VoidCallback? onBuyBank;
  final VoidCallback? onAddToCart;

  const _BundleCard({
    required this.bundle,
    required this.isOwned,
    this.onBuyPoints,
    this.onBuyBank,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = bundle.cards;
    final canBuy = bundle.purchasable;

    return Opacity(
      opacity: canBuy ? 1 : 0.5,
      child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.cardBg,
          AppColors.cardSurface,
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.08), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bundle.name,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text(l10n.cardsIncluded(bundle.cards.length),
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (bundle.hasSale) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.amberGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${bundle.salePercent}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${bundle.originalPrice} KP',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withOpacity(0.6),
                        decoration: TextDecoration.lineThrough,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    canBuy ? '${bundle.discountedPrice} KP' : l10n.owned,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emphasisPositive,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: cards.map((card) {
              final owned = isOwned(card.id);
              final cardColor = ChemicalData.colorForCategory(card.category);

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Opacity(
                  opacity: owned ? 0.4 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(owned ? 0.05 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cardColor.withOpacity(owned ? 0.2 : 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          card.symbol,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: owned ? Colors.white24 : cardColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          owned ? l10n.owned : card.name,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          if (canBuy) ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onBuyPoints,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.amberGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(l10n.buyWithPoints,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                ),
              ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onBuyBank,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(l10n.payWithBank,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  fontFamily: 'Inter')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onAddToCart,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_shopping_cart,
                        color: AppColors.accentText, size: 18),
                    SizedBox(width: 8),
                    Text(l10n.addBundleToCart,
                        style: TextStyle(
                            color: AppColors.accentText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }
}

class _QRModal extends StatelessWidget {
  final int price;
  final String transferCode;
  final String? proofImageUrl;
  final VoidCallback onPickProof;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _QRModal({
    required this.price,
    required this.transferCode,
    required this.proofImageUrl,
    required this.onPickProof,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final qrUrl =
        'https://img.vietqr.io/image/'
        'VCB-1031285717-print.png'
        '?amount=$price'
        '&addInfo=$transferCode'
        '&accountName=NGUYEN%20HOAI%20AN';
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.vnpayPayment,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: 'Inter')),
              const SizedBox(height: 20),
              // QR placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  qrUrl,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.scanQrCodeToPay,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontFamily: 'Inter')),
              const SizedBox(height: 20),
              // Details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    _InfoRow(l10n.receiver, 'Chemistry AR'),
                    const SizedBox(height: 6),
                    _InfoRow(
                      l10n.amount,
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'VND',
                      ).format(price),
                    ),
                    const SizedBox(height: 6),
                    _InfoRow(l10n.transferContent, transferCode),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPickProof,
                  icon: Icon(
                    proofImageUrl == null ? Icons.upload_file : Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    proofImageUrl == null
                        ? l10n.uploadPaymentProof
                        : l10n.paymentProofSelected,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    proofImageUrl == null ? Colors.orange.shade700 : Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: proofImageUrl == null ? null : onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    proofImageUrl == null
                        ? 'Upload proof image first'
                        : l10n.confirmPayment,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.cancel,
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12, color: Colors.black54, fontFamily: 'Inter')),
        Text(value,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Inter')),
      ],
    );
  }
}

class _SingleCardShopTile extends StatelessWidget {
  final SingleCardShopResponse card;
  final bool owned;
  final VoidCallback? onBuy;

  const _SingleCardShopTile({
    required this.card,
    required this.owned,
    required this.onBuy,
  });

  String _formatKp(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K KP';
    }
    return '$value KP';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final borderColor = owned
        ? AppColors.secondary.withOpacity(0.55)
        : AppColors.primary.withOpacity(0.35);

    final displayName = (card.substanceVietnameseName != null &&
        card.substanceVietnameseName!.isNotEmpty)
        ? card.substanceVietnameseName!
        : card.substanceName;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: AspectRatio(
              aspectRatio: 1.55,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlashCardFlipView(
                        substanceFormula: card.substanceFormula,
                        substanceName: displayName,
                        frontImageUrl: card.frontImageUrl,
                        backImageUrl: card.backImageUrl,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  if (owned)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.owned,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.cardBorder.withOpacity(0.35),
                ),
              ),
            ),
            child: owned
                ? Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.emphasisPositive,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.available,
                    style: TextStyle(
                      color: AppColors.emphasisPositive,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatKp(card.kpPrice),
                  style: TextStyle(
                    color: AppColors.textAmber,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onBuy,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.buyNow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
