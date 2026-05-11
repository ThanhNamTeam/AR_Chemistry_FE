import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/chemical_card_widget.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';

class MyBagScreen extends StatelessWidget {
  const MyBagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final unlocked = state.unlockedCards;

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('My Bag',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter')),
                          Text('Your unlocked chemical cards',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Inter')),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.secondary.withOpacity(0.4)),
                      ),
                      child: Text('${unlocked.length} cards',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryLight,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter')),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: unlocked.isEmpty
                    ? _buildEmpty(context)
                    : _buildCardGrid(unlocked),
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
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Your bag is empty',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 8),
          const Text('Purchase chemical cards from the shop',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.shop),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.cyanEmeraldGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 16)
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

  Widget _buildCardGrid(List cards) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: cards.length,
      itemBuilder: (ctx, i) => ChemicalCardWidget(card: cards[i]),
    );
  }
}
