import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../../domain/models/chemical_card_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cartIds = state.cart;
    final List<ChemicalCardModel> cartCards = cartIds
        .map((id) => state.getCardById(id))
        .where((c) => c != null)
        .cast<ChemicalCardModel>()
        .toList();

    final int total = cartCards.fold<int>(0, (sum, c) => sum + c.price);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
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
                      child: Text('Cart',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter')),
                    ),
                    if (cartCards.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          state.clearCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cart cleared',
                                  style: TextStyle(fontFamily: 'Inter')),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Clear',
                            style: TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: cartCards.isEmpty
                    ? _buildEmpty(context)
                    : _buildCartList(context, state, cartCards, total),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.secondary.withOpacity(0.2),
              ]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Your cart is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 8),
          const Text('Add some chemical cards to get started',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.shop),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.cyanEmeraldGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.35), blurRadius: 16)
                ],
              ),
              child: const Text('Go to Shop',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, AppState state, List<ChemicalCardModel> cartCards, int total) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            itemCount: cartCards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final card = cartCards[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52, height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          card.color.withOpacity(0.2),
                          AppColors.cardBg,
                        ]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: card.color.withOpacity(0.5), width: 1.5),
                      ),
                      child: Center(
                        child: Text(card.symbol,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: card.color,
                                fontFamily: 'Inter')),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(card.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter')),
                          const SizedBox(height: 4),
                          Text('Element #${card.atomicNumber}',
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
                        Text('${card.price} KP',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.amberLight,
                                fontFamily: 'Inter')),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => state.removeFromCart(card.id),
                          child: const Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 14),
                              SizedBox(width: 4),
                              Text('Remove',
                                  style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 11,
                                      fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Summary + checkout
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                  color: AppColors.primary.withOpacity(0.2), width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.secondary.withOpacity(0.08),
                  ]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontFamily: 'Inter')),
                        Text('$total KP',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: 'Inter')),
                        Text('$total KP',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight,
                                fontFamily: 'Inter')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  // Purchase all cart items
                  final ids = List<String>.from(state.cart);
                  for (final id in ids) {
                    final card = state.getCardById(id);
                    if (card != null &&
                        state.knowledgePoints >= card.price) {
                      state.purchaseCard(id);
                    }
                  }
                  state.clearCart();
                  Navigator.pushNamed(context, AppRoutes.paymentSuccess);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanEmeraldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 16)
                    ],
                  ),
                  child: const Text('Checkout',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter')),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
