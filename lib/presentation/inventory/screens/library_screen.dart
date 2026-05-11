import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/chemical_card_widget.dart';
import '../../home/providers/app_state.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                    const Text('My Library',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter')),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${state.unlockedCards.length}/${state.cards.length}',
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textCyan,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cardBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.2)),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    gradient: AppColors.cyanEmeraldGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'Unlocked'),
                    Tab(text: 'All Cards'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildGrid(state.unlockedCards),
                    _buildGrid(state.cards),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List cards) {
    if (cards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 56, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('No cards yet',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontFamily: 'Inter')),
            SizedBox(height: 8),
            Text('Visit the shop to get started',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter')),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
