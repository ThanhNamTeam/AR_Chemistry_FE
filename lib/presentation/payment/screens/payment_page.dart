import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../routes/app_navigation.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../home/providers/app_state.dart';
import '../../../domain/models/cart_item_model.dart';
import '../../../domain/models/chemical_card_model.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _showQRModal = false;

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: error ? AppColors.error : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _payWithPoints(AppState state) async {
    final total = state.cartTotalPrice;
    if (state.knowledgePoints < total) {
      _toast('Not enough Knowledge Points', error: true);
      return;
    }
    final ok = await state.checkoutCart('points');
    if (!mounted) return;
    if (ok) {
      _toast('Payment successful!');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        AppNavigation.openMyBag(context);
      }
    }
  }

  void _payWithBank() => setState(() => _showQRModal = true);

  Future<void> _confirmBank(AppState state) async {
    await state.checkoutCart('bank');
    if (!mounted) return;
    setState(() => _showQRModal = false);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.paymentSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.cart;
    final total = state.cartTotalPrice;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
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
                          child: Text('Payment',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter')),
                        ),
                        KnowledgePointsBadge(points: state.knowledgePoints),
                      ],
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text('Cart is empty',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Inter')),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            children: [
                              ...items.map((item) {
                                if (item.type == CartItemType.card) {
                                  final card = state.getCardById(item.id);
                                  if (card == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _CartRow(
                                      title: card.name,
                                      subtitle: card.symbol,
                                      price: state.getCartItemPrice(item),
                                      color: card.color,
                                    ),
                                  );
                                }
                                final bundle = ChemicalData.bundles
                                    .where((b) => b.id == item.id);
                                if (bundle.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                final quote = state.getBundleQuote(item.id);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _CartRow(
                                    title: bundle.first.name,
                                    subtitle:
                                        'Bundle (${quote.remainingCardIds.length} cards)',
                                    price: state.getCartItemPrice(item),
                                    color: AppColors.secondary,
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                            fontFamily: 'Inter')),
                                    Text('$total KP',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryLight,
                                            fontFamily: 'Inter')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _PayButton(
                          label: 'Pay with Knowledge Points',
                          icon: Icons.auto_awesome,
                          gradient: AppColors.amberGradient,
                          onTap: items.isEmpty
                              ? null
                              : () => _payWithPoints(state),
                        ),
                        const SizedBox(height: 12),
                        _PayButton(
                          label: 'Pay with Bank (VNPay)',
                          icon: Icons.credit_card,
                          gradient: AppColors.primaryGradient,
                          onTap: items.isEmpty ? null : _payWithBank,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_showQRModal)
                _QRModal(
                  price: total,
                  onConfirm: () => _confirmBank(state),
                  onCancel: () => setState(() => _showQRModal = false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int price;
  final Color color;

  const _CartRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(subtitle,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontFamily: 'Inter')),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter')),
          ),
          Text('$price KP',
              style: TextStyle(
                  color: AppColors.amberLight,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _PayButton({
    required this.label,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter')),
            ],
          ),
        ),
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
              Text('VNPay Payment',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: 'Inter')),
              const SizedBox(height: 20),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Icon(Icons.qr_code, size: 120, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Text('Amount: ${price * 1000} VND',
                  style: TextStyle(fontFamily: 'Inter')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: Text('Confirm Payment'),
                ),
              ),
              TextButton(onPressed: onCancel, child: Text('Cancel')),
            ],
          ),
        ),
      ),
    );
  }
}
