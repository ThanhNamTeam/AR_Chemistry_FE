import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_portal.dart';
import '../../home/providers/theme_provider.dart';

/// Animated light beam tracing a rounded-rect border clockwise.
class CyberBeamBorder extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const CyberBeamBorder({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<CyberBeamBorder> createState() => _CyberBeamBorderState();
}

class _CyberBeamBorderState extends State<CyberBeamBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beamCtrl;

  @override
  void initState() {
    super.initState();
    _beamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5800),
    )..repeat();
  }

  @override
  void dispose() {
    _beamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final option = context.watch<ThemeProvider>().optionFor(AppPortal.auth);
    final isLight = option.key == AppThemeKey.light;
    final primary = option.primary;
    final primaryLight = Color.lerp(primary, Colors.white, 0.25)!;

    return AnimatedBuilder(
      animation: _beamCtrl,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _RoundedBeamBorderPainter(
            borderRadius: widget.borderRadius,
            accentColor: isLight ? primary : primaryLight,
            showGlow: !isLight,
            beamProgress: _beamCtrl.value,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _RoundedBeamBorderPainter extends CustomPainter {
  _RoundedBeamBorderPainter({
    required this.borderRadius,
    required this.accentColor,
    required this.showGlow,
    required this.beamProgress,
  });

  final BorderRadius borderRadius;
  final Color accentColor;
  final bool showGlow;
  final double beamProgress;

  static const _inset = 1.0;

  Path _borderPath(Size size) {
    return Path()
      ..addRRect(
        borderRadius.toRRect(
          Rect.fromLTWH(
            _inset,
            _inset,
            size.width - _inset * 2,
            size.height - _inset * 2,
          ),
        ),
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _borderPath(size);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final total = metric.length;
    const beamFraction = 0.16;
    final beamLen = total * beamFraction;

    final outerGlow = Paint()
      ..color = accentColor.withOpacity(showGlow ? 0.55 : 0.35)
      ..strokeWidth = showGlow ? 6.0 : 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, showGlow ? 8 : 5);

    final innerBeam = Paint()
      ..color = Colors.white.withOpacity(showGlow ? 0.92 : 0.78)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void drawBeamSegment(double from, double to) {
      if (to <= from) return;
      final segment = metric.extractPath(from, to);
      canvas.drawPath(segment, outerGlow);
      canvas.drawPath(segment, innerBeam);
    }

    void drawBeamAtProgress(double progress) {
      final normalized = progress - progress.floor();
      final start = normalized * total;
      final end = start + beamLen;

      if (end <= total) {
        drawBeamSegment(start, end);
      } else {
        drawBeamSegment(start, total);
        drawBeamSegment(0, end - total);
      }
    }

    drawBeamAtProgress(beamProgress);
    drawBeamAtProgress(beamProgress + 0.5);
  }

  @override
  bool shouldRepaint(covariant _RoundedBeamBorderPainter oldDelegate) {
    return oldDelegate.beamProgress != beamProgress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.showGlow != showGlow ||
        oldDelegate.borderRadius != borderRadius;
  }
}
