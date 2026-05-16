import 'package:flutter/material.dart';
import '../../shared/styles/app_colors.dart';
import '../../domain/models/chemical_card_model.dart';

class ChemicalCardWidget extends StatelessWidget {
  final ChemicalCardModel card;
  final VoidCallback? onTap;
  final VoidCallback? onBuyWithPoints;
  final VoidCallback? onBuyWithBank;
  final VoidCallback? onAddToCart;
  final bool showBuyButtons;
  final bool ownedInShop;

  const ChemicalCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.onBuyWithPoints,
    this.onBuyWithBank,
    this.onAddToCart,
    this.showBuyButtons = false,
    this.ownedInShop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOwned = ownedInShop;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isOwned ? 0.45 : 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.cardBg,
                AppColors.cardBg.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: card.isUnlocked || isOwned
                  ? card.color.withOpacity(isOwned ? 0.25 : 0.5)
                  : AppColors.cardBorder.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: card.isUnlocked && !isOwned
                ? [
                    BoxShadow(
                      color: card.color.withOpacity(0.2),
                      blurRadius: 16,
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    if (card.isUnlocked && !isOwned)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: RadialGradient(
                              colors: [
                                card.color.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (!card.isUnlocked && !isOwned)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock,
                              color: Colors.white30,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    if (isOwned)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.black.withOpacity(0.55),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_circle_outline,
                              color: Colors.white54,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (card.atomicNumber > 0)
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${card.atomicNumber}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOwned
                                      ? Colors.white24
                                      : card.color.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            card.symbol,
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: isOwned
                                  ? Colors.white24
                                  : (card.isUnlocked
                                      ? card.color
                                      : Colors.white24),
                            ),
                          ),
                          Text(
                            card.name,
                            style: TextStyle(
                              fontSize: 11,
                              color: isOwned
                                  ? Colors.white24
                                  : (card.isUnlocked
                                      ? Colors.white70
                                      : Colors.white24),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (showBuyButtons && !isOwned) ...[
                Divider(
                  height: 1,
                  color: AppColors.cardBorder.withOpacity(0.3),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        '${card.price} KP',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.amberLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallButton(
                              label: 'KP',
                              icon: Icons.auto_awesome,
                              color: AppColors.amber,
                              onTap: onBuyWithPoints,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildSmallButton(
                              label: 'Bank',
                              icon: Icons.qr_code,
                              color: AppColors.accent,
                              onTap: onBuyWithBank,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_shopping_cart,
                                  size: 12, color: AppColors.primaryLight),
                              SizedBox(width: 4),
                              Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: AppColors.primaryLight,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
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
              if (isOwned)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Owned',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.8),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 10, color: Colors.white),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
