import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../shared/widgets/chemical_card_widget.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../../domain/models/chemical_card_model.dart';

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

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: isError ? AppColors.error : AppColors.secondary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _buyWithPoints(AppState state, String id, int price, String type) {
    if (state.knowledgePoints >= price) {
      if (type == 'card') {
        state.purchaseCard(id);
        _showToast('Card purchased! Check your bag.');
      } else {
        state.purchaseBundle(id);
        _showToast('Bundle added to your bag!');
      }
    } else {
      _showToast('Not enough Knowledge Points', isError: true);
    }
  }

  void _openQR(String id, int price, String type) {
    setState(() {
      _selectedId = id;
      _selectedPrice = price;
      _selectedType = type;
      _showQRModal = true;
    });
  }

  void _confirmQRPayment(AppState state) {
    if (_selectedId != null) {
      if (_selectedType == 'card') {
        state.purchaseCard(_selectedId!);
      } else {
        state.purchaseBundle(_selectedId!);
      }
      setState(() => _showQRModal = false);
      Navigator.pushNamed(context, AppRoutes.paymentSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locked = state.lockedCards;
    final bundles = ChemicalData.bundles;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.primary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
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
                                child: const Icon(Icons.shopping_cart_outlined,
                                    color: AppColors.primary, size: 20),
                              ),
                              if (state.cart.isNotEmpty)
                                Positioned(
                                  top: 2, right: 2,
                                  child: Container(
                                    width: 16, height: 16,
                                    decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('${state.cart.length}',
                                          style: const TextStyle(
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
                              const Icon(Icons.inventory_2_outlined,
                                  color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              const Text('Bundle Packs',
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
                                child: const Text('Save 20%',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.secondaryLight,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...bundles.map((b) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _BundleCard(
                                  bundle: b,
                                  allCards: state.cards,
                                  onBuyPoints: () => _buyWithPoints(
                                      state, b.id, b.discountedPrice, 'bundle'),
                                  onBuyBank: () =>
                                      _openQR(b.id, b.discountedPrice, 'bundle'),
                                ),
                              )),

                          const SizedBox(height: 8),
                          const Text('Single Cards',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter')),
                          const SizedBox(height: 14),

                          if (locked.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Text("You've unlocked all cards! 🎉",
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontFamily: 'Inter')),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                              itemCount: locked.length,
                              itemBuilder: (ctx, i) {
                                final card = locked[i];
                                return ChemicalCardWidget(
                                  card: card,
                                  showBuyButtons: true,
                                  onBuyWithPoints: () => _buyWithPoints(
                                      state, card.id, card.price, 'card'),
                                  onBuyWithBank: () =>
                                      _openQR(card.id, card.price, 'card'),
                                  onAddToCart: () {
                                    state.addToCart(card.id);
                                    _showToast('Added to cart!');
                                  },
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
  final BundleModel bundle;
  final List<ChemicalCardModel> allCards;
  final VoidCallback onBuyPoints;
  final VoidCallback onBuyBank;

  const _BundleCard({
    required this.bundle,
    required this.allCards,
    required this.onBuyPoints,
    required this.onBuyBank,
  });

  @override
  Widget build(BuildContext context) {
    final cards =
        bundle.cardIds.map((id) => allCards.firstWhere((c) => c.id == id, orElse: () => allCards.first)).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.cardBg,
          AppColors.cardBg.withOpacity(0.6),
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
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter')),
                    const SizedBox(height: 4),
                    Text('${bundle.cardIds.length} cards included',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${bundle.originalPrice} KP',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.6),
                          decoration: TextDecoration.lineThrough,
                          fontFamily: 'Inter')),
                  Text('${bundle.discountedPrice} KP',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryLight,
                          fontFamily: 'Inter')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: cards.map((card) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: card.color.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text(card.symbol,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: card.color,
                            fontFamily: 'Inter')),
                    Text(card.name,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),
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
                    child: const Row(
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card, color: Colors.white, size: 16),
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
        ],
      ),
    );
  }
}

class _QRModal extends StatelessWidget {
  final int price;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _QRModal({
    required this.price,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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
              const Text('VNPay Payment',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: 'Inter')),
              const SizedBox(height: 20),
              // QR placeholder
              Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: const Icon(Icons.qr_code,
                    size: 120, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text('Scan QR code to pay',
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
                    _InfoRow('Amount', '${(price * 1000).toString()} VND'),
                    const SizedBox(height: 6),
                    _InfoRow('Content', 'Chemistry AR Card'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirm Payment',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter')),
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
                  child: const Text('Cancel',
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
            style: const TextStyle(
                fontSize: 12, color: Colors.black54, fontFamily: 'Inter')),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Inter')),
      ],
    );
  }
}
