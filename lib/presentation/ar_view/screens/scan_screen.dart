import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../../routes/app_routes.dart';
import '../../home/providers/app_state.dart';
import '../../../domain/models/chemical_card_model.dart';
import '../widgets/ar_camera_view.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  late AnimationController _scanCtrl;
  late Animation<double> _scanAnim;
  late AnimationController _pulseCtrl;
  late final Widget _arCameraView;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[AR_UNITY_TIMING] ScanScreen initState');
    _arCameraView = const ARCameraView(key: ValueKey('stable-ar-camera-view'));
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
    debugPrint('[AR_UNITY_TIMING] ScanScreen dispose');
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _simulateScan(AppState state) async {
    if (state.unlockedCards.length < 2) {
      debugPrint('[AR_UNITY_TIMING] ScanScreen simulateScan blocked=notEnoughCards');
      _toast('You need at least 2 unlocked cards to experiment');
      return;
    }
    if (_scanning) {
      debugPrint('[AR_UNITY_TIMING] ScanScreen simulateScan blocked=alreadyScanning');
      return;
    }

    final available = state.unlockedCards
        .where((c) => !state.scannedCards.contains(c.id))
        .toList();
    if (available.isEmpty) {
      debugPrint('[AR_UNITY_TIMING] ScanScreen simulateScan blocked=noAvailableCards');
      return;
    }

    debugPrint('[AR_UNITY_TIMING] ScanScreen scanning=true');
    setState(() => _scanning = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final card = available.first;
    state.addScannedCard(card.id);
    debugPrint('[AR_UNITY_TIMING] ScanScreen scanning=false card=${card.id}');
    setState(() => _scanning = false);
    _toast('Scanned: ${card.symbol} - ${card.name}');
  }

  void _goToResult(AppState state) {
    if (state.scannedCards.length < 2) {
      debugPrint('[AR_UNITY_TIMING] ScanScreen goToResult blocked=notEnoughScans');
      return;
    }
    debugPrint('[AR_UNITY_TIMING] ScanScreen goToResult');
    Navigator.pushNamed(
      context,
      AppRoutes.result,
      arguments: state.scannedCards.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[AR_UNITY_TIMING] ScanScreen build');
    final state = context.watch<AppState>();
    final scanned = state.scannedCards
        .map((id) => state.getCardById(id))
        .where((c) => c != null)
        .cast<ChemicalCardModel>()
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
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
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
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
                                Positioned.fill(
                                  child: _arCameraView,
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
                                          child: Icon(
                                            Icons.qr_code_scanner,
                                            color: AppColors.primary,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
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
                        Align(
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
                                  child: Icon(
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

                      if (state.unlockedCards.length < 2)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Unlock at least 2 cards in your library to run experiments',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: _scanning ? null : () => _simulateScan(state),
                        child: Opacity(
                          opacity: _scanning ? 0.6 : 1,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: AppColors.cyanEmeraldGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_scanning)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  Icon(Icons.document_scanner,
                                      color: Colors.white, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  _scanning
                                      ? 'Scanning...'
                                      : scanned.isEmpty
                                          ? 'Scan Card 1'
                                          : scanned.length == 1
                                              ? 'Scan Card 2'
                                              : 'Scan again',
                                  style: TextStyle(
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
                      ),
                      const SizedBox(height: 12),
                      if (scanned.length >= 2)
                        GestureDetector(
                          onTap: () => _goToResult(state),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.5)),
                            ),
                            child: Text(
                              'Run Experiment',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.secondaryLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      if (scanned.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: state.clearScannedCards,
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
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
    final color = AppColors.primary;
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
