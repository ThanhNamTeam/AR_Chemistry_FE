import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/models/response/card_bundle_response.dart';
import '../../../core/models/response/single_card_purchase_response.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../shared/widgets/flash_card_flip_view.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../home/providers/theme_provider.dart';
import '../../../domain/models/chemical_card_model.dart';
import 'package:intl/intl.dart';

import 'package:image_picker/image_picker.dart';

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

      state.loadShopSingleCards(refresh: true);
      state.loadMySingleCards(refresh: true);
      state.loadShopCardBundles(refresh: true);
    });
  }

  Future<void> _saveQrToGallery(String? qrImageUrl) async {
    if (qrImageUrl == null || qrImageUrl.isEmpty) {
      _showToast('QR image is not available', isError: true);
      return;
    }

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

      await Gal.putImage(filePath);

      _showToast('QR saved to gallery');
    } catch (e) {
      debugPrint('Save QR error: $e');
      _showToast('Save QR failed', isError: true);
    }
  }

  void _showPurchasedQrDialog(SingleCardPurchaseResponse purchase) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          purchase.singleCardName,
          style: const TextStyle(
            color: Colors.white,
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
                'QR image is not available.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'QR Content: ${purchase.qrContent}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              purchase.expiredAt == null
                  ? ''
                  : 'Expires at: ${DateFormat('dd/MM/yyyy HH:mm').format(purchase.expiredAt!)}',
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
            child: const Text('Save QR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: isError ? AppColors.error : AppColors.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _fakeBuySingleCard(AppState state, String singleCardId) async {
    final purchase = await state.fakeBuySingleCard(singleCardId);

    if (!mounted) return;

    if (purchase == null) {
      _showToast('Buy single card failed', isError: true);
      return;
    }

    _showToast('Card purchased successfully!');
    _showPurchasedQrDialog(purchase);
  }

  Future<void> _buyWithPoints(
      AppState state, String id, int price, String type) async {
    if (state.knowledgePoints < price) {
      _showToast('Not enough Knowledge Points', isError: true);
      return;
    }

    final ok = type == 'CHEMICAL_CARD'
        ? await state.purchaseCard(id)
        : await state.purchaseBundle(id);

    if (!mounted) return;

    if (ok) {
      _showToast(type == 'CHEMICAL_CARD'
          ? 'Card purchased! Check your bag.'
          : 'Bundle added to your bag!');
    } else {
      _showToast('Not enough Knowledge Points', isError: true);
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
      _showToast('Upload proof image failed', isError: true);
      return;
    }

    setState(() {
      _proofImageUrl = fileUrl;
    });

    _showToast('Proof image uploaded successfully');
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
      _showToast('Please upload payment proof image first', isError: true);
      return;
    }

    final ok = await state.createBankPayment(
      itemId: _selectedId!,
      itemType: _selectedType,
      proofImageUrl: _proofImageUrl!,
    );

    if (!mounted) return;

    if (!ok) {
      _showToast('Create payment failed', isError: true);
      return;
    }

    setState(() => _showQRModal = false);

    _showToast('Payment submitted. Please wait for staff approval.');

    Navigator.pushNamed(context, AppRoutes.paymentSuccess);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final state = context.watch<AppState>();
    final catalog = state.shopSingleCards

        .map((card) => ChemicalCardModel(
              id: card.id,
              symbol: card.substanceFormula,
              name: (card.substanceVietnameseName != null &&
                      card.substanceVietnameseName!.isNotEmpty)
                  ? card.substanceVietnameseName!
                  : card.substanceName,
              atomicNumber: 0,
              color: AppColors.primary,
              price: card.price,
              category: CardCategory.element,
              isUnlocked: state.isSingleCardOwned(card.id),
              frontImageUrl: card.frontImageUrl,
              backImageUrl: card.backImageUrl,
            ))
        .toList();
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Icon(Icons.arrow_back,
                                color: AppColors.primary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text('Shop',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter')),
                        ),
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
                              Text('Bundle Packs',
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
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.secondary.withOpacity(0.4)),
                                ),
                                child: Text('Up to 20% off',
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
                                      _showToast('Bundle added to cart!');
                                    }
                                  }
                                      : null,
                                ),
                              );
                            }),
                          ],

                          const SizedBox(height: 8),
                          Text(
                            'Single Cards',
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
                              itemCount: catalog.length,
                              itemBuilder: (ctx, i) {
                                final card = catalog[i];

                                final owned = state.isSingleCardOwned(card.id);

                                return _SingleCardShopTile(
                                  card: card,
                                  owned: owned,
                                  onBuy: owned ? null : () => _fakeBuySingleCard(state, card.id),
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
        borderRadius: BorderRadius.circular(20),
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
                    Text('${bundle.cards.length} cards included',
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
                        borderRadius: BorderRadius.circular(8),
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
                    canBuy ? '${bundle.discountedPrice} KP' : 'Owned',
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
                      borderRadius: BorderRadius.circular(10),
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
                          owned ? 'Owned' : card.name,
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
                        Text('Buy with Points',
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
                          Text('Pay with Bank',
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
                    Text('Add Bundle to Cart',
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('VNPay Payment',
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
              Text('Scan QR code to pay',
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
                    _InfoRow('Receiver', 'Chemistry AR'),
                    const SizedBox(height: 6),
                    _InfoRow(
                      'Amount',
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'VND',
                      ).format(price),
                    ),
                    const SizedBox(height: 6),
                    _InfoRow('Content', transferCode),
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
                        ? 'Upload payment proof'
                        : 'Payment proof selected',
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
                        : 'Confirm Payment',
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
                  child: Text('Cancel',
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
  final ChemicalCardModel card;
  final bool owned;
  final VoidCallback? onBuy;

  const _SingleCardShopTile({
    required this.card,
    required this.owned,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = owned
        ? AppColors.secondary.withOpacity(0.55)
        : AppColors.primary.withOpacity(0.35);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
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
                        substanceFormula: card.symbol,
                        substanceName: card.name,
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
                        child: const Text(
                          'Owned',
                          style: TextStyle(
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
                borderRadius: BorderRadius.circular(14),
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
                    'Available',
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
                  '${card.price} KP',
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Buy Now',
                          style: TextStyle(
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
