import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/cart_item_model.dart';
import '../../../domain/models/chemical_card_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final items = state.cart;
    final total = state.cartTotalPrice;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Icon(Icons.arrow_back,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(l10n.cart,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter')),
                    ),
                    if (items.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          state.clearCart();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.cartCleared,
                                  style: TextStyle(fontFamily: 'Inter')),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(l10n.clear,
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
                child: items.isEmpty
                    ? _buildEmpty(context)
                    : _buildCartList(context, state, items, total),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.secondary.withValues(alpha: 0.2),
              ]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.shopping_cart_outlined,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          Text(l10n.cartEmpty,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Text(l10n.cartEmptyHint,
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(l10n.goToShop,
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

  Widget _buildCartList(
    BuildContext context,
    AppState state,
    List<CartItem> items,
    int total,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final item = items[i];
              if (item.type == CartItemType.card) {
                final card = state.getCardById(item.id);
                if (card == null) return const SizedBox.shrink();
                return _CartCardRow(
                  title: card.name,
                  subtitle: 'Single card · ${card.symbol}',
                  price: state.getCartItemPrice(item),
                  color: card.color,
                  symbol: card.symbol,
                  onRemove: () => state.removeCartItem(item),
                );
              }
              final bundleMatches =
                  ChemicalData.bundles.where((b) => b.id == item.id);
              if (bundleMatches.isEmpty) return const SizedBox.shrink();
              final bundle = bundleMatches.first;
              final quote = state.getBundleQuote(item.id);
              return _CartCardRow(
                title: bundle.name,
                subtitle:
                    'Bundle · ${quote.remainingCardIds.length} card(s)',
                price: state.getCartItemPrice(item),
                color: AppColors.secondary,
                symbol: '📦',
                onRemove: () => state.removeCartItem(item),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2), width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.total,
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
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.payment),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.cyanEmeraldGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(l10n.proceedToPayment,
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

class _CartCardRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int price;
  final Color color;
  final String symbol;
  final VoidCallback onRemove;

  const _CartCardRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.color,
    required this.symbol,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                color.withValues(alpha: 0.2),
                AppColors.cardBg,
              ]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Center(
              child: Text(symbol,
                  style: TextStyle(
                      fontSize: symbol.length > 2 ? 22 : 20,
                      fontWeight: FontWeight.w900,
                      color: color,
                      fontFamily: 'Inter')),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter')),
                const SizedBox(height: 4),
                Text(subtitle,
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
              Text('$price KP',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.amberLight,
                      fontFamily: 'Inter')),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onRemove,
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        color: AppColors.error, size: 14),
                    SizedBox(width: 4),
                    Text(l10n.remove,
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
  }
}
