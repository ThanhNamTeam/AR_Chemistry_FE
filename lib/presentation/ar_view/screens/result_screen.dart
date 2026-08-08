import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../../domain/models/chemical_card_model.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _revealCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _pointsAdded = false;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = CurvedAnimation(parent: _revealCtrl, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showResult = true);
        _revealCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final args = ModalRoute.of(context)?.settings.arguments;
    List<String> scannedIds = [];
    if (args is List<String>) scannedIds = args;

    final card1 =
        scannedIds.isNotEmpty ? state.getCardById(scannedIds[0]) : null;
    final card2 =
        scannedIds.length > 1 ? state.getCardById(scannedIds[1]) : null;

    if (card1 == null || card2 == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.textSecondary, size: 56),
              const SizedBox(height: 16),
              Text(l10n.noExperimentData,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Inter')),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: l10n.goToScan,
                onTap: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.scan),
              ),
            ],
          ),
        ),
      );
    }

    final reaction = ChemicalData.getReaction(card1.symbol, card2.symbol);

    if (!_pointsAdded) {
      _pointsAdded = true;
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          state.addKnowledgePoints(reaction.points);
          state.clearScannedCards();
        }
      });
    }

    if (!_showResult) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // BG blobs
            Positioned(
              top: 80, left: 10,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 80, right: 10,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(l10n.experimentResult,
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

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Column(
                        children: [
                          // Reaction visual
                          ScaleTransition(
                            scale: _scaleAnim,
                            child: FadeTransition(
                              opacity: _fadeAnim,
                              child: _buildReactionVisual(card1, card2),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Details card
                          SlideTransition(
                            position: _slideAnim,
                            child: FadeTransition(
                              opacity: _fadeAnim,
                              child: _buildDetailsCard(reaction, card1, card2),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Points earned card
                          FadeTransition(
                            opacity: _fadeAnim,
                            child: _buildPointsCard(reaction.points),
                          ),
                          const SizedBox(height: 24),

                          // Actions
                          Row(
                            children: [
                              Expanded(
                                child:                               _PrimaryButton(
                                  label: l10n.newExperiment,
                                  onTap: () => Navigator.pushReplacementNamed(
                                      context, AppRoutes.scan),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppRoutes.home,
                                          (r) => false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.home_outlined,
                                            color: AppColors.textPrimary,
                                            size: 20),
                                        SizedBox(width: 8),
                                        Text(l10n.home,
                                            style: TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionVisual(ChemicalCardModel c1, ChemicalCardModel c2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CardChip(card: c1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('+',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight)),
        ),
        _CardChip(card: c2),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.arrow_forward,
              color: AppColors.secondary, size: 28),
        ),
        // Product
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.secondary.withValues(alpha: 0.2),
              AppColors.primary.withValues(alpha: 0.2),
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.25), blurRadius: 16)
            ],
          ),
          child: Text(
            '${c1.symbol}${c2.symbol}',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.secondaryLight,
                fontFamily: 'Inter'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(ChemicalReaction reaction, ChemicalCardModel c1,
      ChemicalCardModel c2) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reaction.name,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 14),
          // Equation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
            ),
            child: Text(reaction.equation,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 18,
                    color: AppColors.secondaryLight,
                    letterSpacing: 1)),
          ),
          const SizedBox(height: 14),
          Text(reaction.description,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildPointsCard(int points) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.amber.withValues(alpha: 0.15),
          AppColors.amberDark.withValues(alpha: 0.15),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(l10n.knowledgePointsEarned,
              style: TextStyle(
                  color: AppColors.textAmber,
                  fontSize: 13,
                  fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Text('+$points',
              style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.amberLight,
                  fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: AppColors.amber, size: 16),
              SizedBox(width: 6),
              Text(l10n.keepExperimentingEarnMore,
                  style: TextStyle(
                      color: AppColors.amberLight,
                      fontSize: 12,
                      fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  final ChemicalCardModel card;
  const _CardChip({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          card.color.withValues(alpha: 0.15),
          AppColors.cardBg,
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: card.color.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(color: card.color.withValues(alpha: 0.25), blurRadius: 12)
        ],
      ),
      child: Text(card.symbol,
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: card.color,
              fontFamily: 'Inter')),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.cyanEmeraldGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 16)
          ],
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter')),
      ),
    );
  }
}
