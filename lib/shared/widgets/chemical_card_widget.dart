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

  const ChemicalCardWidget({
    super.key,
    required this.card,
    this.onTap,
    this.onBuyWithPoints,
    this.onBuyWithBank,
    this.onAddToCart,
    this.showBuyButtons = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            color: card.isUnlocked
                ? card.color.withOpacity(0.5)
                : AppColors.cardBorder.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: card.isUnlocked
              ? [
                  BoxShadow(
                    color: card.color.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 0,
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            // Card body
            Expanded(
              child: Stack(
                children: [
                  // Background glow
                  if (card.isUnlocked)
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

                  // Locked overlay
                  if (!card.isUnlocked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white30,
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Atomic number
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '${card.atomicNumber}',
                            style: TextStyle(
                              fontSize: 11,
                              color: card.isUnlocked
                                  ? card.color.withOpacity(0.8)
                                  : Colors.white30,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Symbol
                        Text(
                          card.symbol,
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: card.isUnlocked ? card.color : Colors.white24,
                            shadows: card.isUnlocked
                                ? [
                                    Shadow(
                                      color: card.color.withOpacity(0.6),
                                      blurRadius: 12,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                        // Name
                        Text(
                          card.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: card.isUnlocked
                                ? Colors.white70
                                : Colors.white24,
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

            // Buy buttons (only for shop)
            if (showBuyButtons && !card.isUnlocked) ...[
              Divider(
                height: 1,
                color: AppColors.cardBorder.withOpacity(0.3),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Price
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
                  ],
                ),
              ),
            ],
          ],
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
              style: const TextStyle(
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
