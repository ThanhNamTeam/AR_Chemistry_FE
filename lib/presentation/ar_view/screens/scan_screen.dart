import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../../domain/models/chemical_card_model.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late Animation<double> _scanAnim;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut));
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _simulateScan(AppState state) {
    final unlockedCards = state.unlockedCards;
    if (unlockedCards.isEmpty) return;
    final available = unlockedCards
        .where((c) => !state.scannedCards.contains(c.id))
        .toList();
    if (available.isEmpty) {
      if (state.scannedCards.length >= 2) {
        _goToResult(state);
      }
      return;
    }
    final card = available.first;
    state.addScannedCard(card.id);
    if (state.scannedCards.length >= 2) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _goToResult(state);
      });
    }
  }

  void _goToResult(AppState state) {
    Navigator.pushNamed(
      context,
      AppRoutes.result,
      arguments: state.scannedCards.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scanned = state.scannedCards
        .map((id) => state.getCardById(id))
        .where((c) => c != null)
        .cast<ChemicalCardModel>()
        .toList();

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
                      onTap: () {
                        state.clearScannedCards();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'AR Scanner',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    KnowledgePointsBadge(points: state.knowledgePoints),
                  ],
                ),
              ),

              // Scanner viewfinder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Viewfinder
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Stack(
                              children: [
                                // Fake camera background
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.05),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),

                                // Corner markers
                                ..._buildCorners(),

                                // Scanning line
                                AnimatedBuilder(
                                  animation: _scanAnim,
                                  builder: (_, __) {
                                    return Positioned(
                                      top:
                                          _scanAnim.value *
                                          (MediaQuery.of(context).size.height *
                                              0.35),
                                      left: 20,
                                      right: 20,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          gradient:
                                              AppColors.cyanEmeraldGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.6),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Center text
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _pulseCtrl,
                                        builder: (_, child) => Opacity(
                                          opacity: 0.5 + 0.5 * _pulseCtrl.value,
                                          child: child,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.qr_code_scanner,
                                            color: AppColors.primary,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Point camera at a\nchemical card',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Scanned cards row
                      if (scanned.isNotEmpty) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Scanned Cards',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...scanned.map(
                                (card) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _ScannedCardChip(card: card),
                                ),
                              ),
                              if (scanned.length < 2)
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.textSecondary
                                          .withOpacity(0.3),
                                      style: BorderStyle.solid,
                                      width: 1.5,
                                    ),
                                    color: AppColors.cardBg.withOpacity(0.3),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.textSecondary,
                                    size: 24,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Simulate scan button
                      GestureDetector(
                        onTap: () => _simulateScan(state),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: AppColors.cyanEmeraldGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.document_scanner,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                scanned.isEmpty
                                    ? 'Simulate Scan (Card 1)'
                                    : scanned.length == 1
                                    ? 'Simulate Scan (Card 2)'
                                    : 'View Result',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (scanned.isNotEmpty)
                        GestureDetector(
                          onTap: state.clearScannedCards,
                          child: const Text(
                            'Clear',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 24.0;
    const stroke = 3.0;
    const color = AppColors.primary;
    return [
      Positioned(
        top: 20,
        left: 20,
        child: _Corner(
          size: size,
          stroke: stroke,
          color: color,
          top: true,
          left: true,
        ),
      ),
      Positioned(
        top: 20,
        right: 20,
        child: _Corner(
          size: size,
          stroke: stroke,
          color: color,
          top: true,
          left: false,
        ),
      ),
      Positioned(
        bottom: 20,
        left: 20,
        child: _Corner(
          size: size,
          stroke: stroke,
          color: color,
          top: false,
          left: true,
        ),
      ),
      Positioned(
        bottom: 20,
        right: 20,
        child: _Corner(
          size: size,
          stroke: stroke,
          color: color,
          top: false,
          left: false,
        ),
      ),
    ];
  }
}

class _Corner extends StatelessWidget {
  final double size;
  final double stroke;
  final Color color;
  final bool top;
  final bool left;

  const _Corner({
    required this.size,
    required this.stroke,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          stroke: stroke,
          color: color,
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double stroke;
  final Color color;
  final bool top;
  final bool left;

  _CornerPainter({
    required this.stroke,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final xEnd = left ? size.width : 0.0;
    final yEnd = top ? size.height : 0.0;

    canvas.drawLine(Offset(x, y), Offset(xEnd, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, yEnd), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannedCardChip extends StatelessWidget {
  final ChemicalCardModel card;

  const _ScannedCardChip({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [card.color.withOpacity(0.2), AppColors.cardBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: card.color.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: card.color.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Center(
        child: Text(
          card.symbol,
          style: TextStyle(
            color: card.color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
