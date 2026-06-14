import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_portal.dart';
import '../../home/providers/theme_provider.dart';

/// Sci-fi HUD-style frame for the login form card.
class CyberLoginFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CyberLoginFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(28, 32, 28, 28),
  });

  @override
  Widget build(BuildContext context) {
    final option = context.watch<ThemeProvider>().optionFor(AppPortal.auth);
    final isLight = option.key == AppThemeKey.light;
    final primary = option.primary;
    final primaryLight = Color.lerp(primary, Colors.white, 0.25)!;

    return CustomPaint(
      painter: _CyberFramePainter(
        borderColor: isLight
            ? primary.withOpacity(0.55)
            : primary.withOpacity(0.9),
        accentColor: isLight ? primary : primaryLight,
        fillColor: _frameFillColor(option),
        showGlow: !isLight,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  Color _frameFillColor(AppThemeOption option) {
    final primary = option.primary;
    if (option.key == AppThemeKey.light) {
      return Color.alphaBlend(
        primary.withOpacity(0.08),
        const Color(0xFFFFFFFF),
      ).withOpacity(0.92);
    }
    return Color.alphaBlend(
      primary.withOpacity(0.22),
      const Color(0xFF0F172A),
    ).withOpacity(0.86);
  }
}

class _CyberFrameGeometry {
  static const inset = 1.0;
  static const cornerLen = 20.0;
  static const edgeInset = 38.0;
  static const sideInset = 34.0;
  static const flareHalf = 26.0;
}

class _CyberFramePainter extends CustomPainter {
  _CyberFramePainter({
    required this.borderColor,
    required this.accentColor,
    required this.fillColor,
    required this.showGlow,
  });

  final Color borderColor;
  final Color accentColor;
  final Color fillColor;
  final bool showGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(
        _CyberFrameGeometry.inset,
        _CyberFrameGeometry.inset,
        w - _CyberFrameGeometry.inset * 2,
        h - _CyberFrameGeometry.inset * 2,
      ),
      Paint()..color = fillColor,
    );

    final edgePaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = accentColor.withOpacity(0.45)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    void drawLine(Offset a, Offset b, Paint paint) {
      canvas.drawLine(a, b, paint);
    }

    void drawSegment(Offset a, Offset b) {
      if (showGlow) drawLine(a, b, glowPaint);
      drawLine(a, b, edgePaint);
    }

    drawSegment(Offset(_CyberFrameGeometry.edgeInset, _CyberFrameGeometry.inset), Offset(w / 2 - _CyberFrameGeometry.flareHalf - 3, _CyberFrameGeometry.inset));
    drawSegment(Offset(w / 2 + _CyberFrameGeometry.flareHalf + 3, _CyberFrameGeometry.inset), Offset(w - _CyberFrameGeometry.edgeInset, _CyberFrameGeometry.inset));
    drawSegment(
      Offset(_CyberFrameGeometry.edgeInset, h - _CyberFrameGeometry.inset),
      Offset(w / 2 - _CyberFrameGeometry.flareHalf - 3, h - _CyberFrameGeometry.inset),
    );
    drawSegment(
      Offset(w / 2 + _CyberFrameGeometry.flareHalf + 3, h - _CyberFrameGeometry.inset),
      Offset(w - _CyberFrameGeometry.edgeInset, h - _CyberFrameGeometry.inset),
    );

    drawSegment(Offset(_CyberFrameGeometry.inset, _CyberFrameGeometry.sideInset), Offset(_CyberFrameGeometry.inset, h - _CyberFrameGeometry.sideInset));
    drawSegment(Offset(w - _CyberFrameGeometry.inset, _CyberFrameGeometry.sideInset), Offset(w - _CyberFrameGeometry.inset, h - _CyberFrameGeometry.sideInset));

    _drawCornerBracket(
      canvas,
      Offset(_CyberFrameGeometry.inset, _CyberFrameGeometry.inset),
      accentPaint,
      showGlow: showGlow,
    );
    _drawCornerBracket(
      canvas,
      Offset(w - _CyberFrameGeometry.inset, _CyberFrameGeometry.inset),
      accentPaint,
      showGlow: showGlow,
      flipX: true,
    );
    _drawCornerBracket(
      canvas,
      Offset(w - _CyberFrameGeometry.inset, h - _CyberFrameGeometry.inset),
      accentPaint,
      showGlow: showGlow,
      flipX: true,
      flipY: true,
    );
    _drawCornerBracket(
      canvas,
      Offset(_CyberFrameGeometry.inset, h - _CyberFrameGeometry.inset),
      accentPaint,
      showGlow: showGlow,
      flipY: true,
    );

    if (showGlow) {
      drawLine(
        Offset(w / 2 - _CyberFrameGeometry.flareHalf, _CyberFrameGeometry.inset),
        Offset(w / 2 + _CyberFrameGeometry.flareHalf, _CyberFrameGeometry.inset),
        glowPaint,
      );
      drawLine(
        Offset(w / 2 - _CyberFrameGeometry.flareHalf, h - _CyberFrameGeometry.inset),
        Offset(w / 2 + _CyberFrameGeometry.flareHalf, h - _CyberFrameGeometry.inset),
        glowPaint,
      );
    }
    drawLine(
      Offset(w / 2 - _CyberFrameGeometry.flareHalf, _CyberFrameGeometry.inset),
      Offset(w / 2 + _CyberFrameGeometry.flareHalf, _CyberFrameGeometry.inset),
      accentPaint,
    );
    drawLine(
      Offset(w / 2 - _CyberFrameGeometry.flareHalf, h - _CyberFrameGeometry.inset),
      Offset(w / 2 + _CyberFrameGeometry.flareHalf, h - _CyberFrameGeometry.inset),
      accentPaint,
    );

    final notchPaint = Paint()
      ..color = accentColor.withOpacity(0.75)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const notch = 8.0;
    canvas.drawPath(
      Path()
        ..moveTo(_CyberFrameGeometry.inset + _CyberFrameGeometry.cornerLen, _CyberFrameGeometry.inset)
        ..lineTo(_CyberFrameGeometry.inset + _CyberFrameGeometry.cornerLen + notch, _CyberFrameGeometry.inset)
        ..lineTo(_CyberFrameGeometry.inset + _CyberFrameGeometry.cornerLen + notch, _CyberFrameGeometry.inset + notch),
      notchPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - _CyberFrameGeometry.inset - _CyberFrameGeometry.cornerLen, _CyberFrameGeometry.inset)
        ..lineTo(w - _CyberFrameGeometry.inset - _CyberFrameGeometry.cornerLen - notch, _CyberFrameGeometry.inset)
        ..lineTo(w - _CyberFrameGeometry.inset - _CyberFrameGeometry.cornerLen - notch, _CyberFrameGeometry.inset + notch),
      notchPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(_CyberFrameGeometry.inset + _CyberFrameGeometry.cornerLen, h - _CyberFrameGeometry.inset)
        ..lineTo(_CyberFrameGeometry.inset + _CyberFrameGeometry.cornerLen + notch, h - _CyberFrameGeometry.inset)
        ..lineTo(_CyberFrameGeometry.inset + _CyberFrameGeometry.cornerLen + notch, h - _CyberFrameGeometry.inset - notch),
      notchPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - _CyberFrameGeometry.inset - _CyberFrameGeometry.cornerLen, h - _CyberFrameGeometry.inset)
        ..lineTo(w - _CyberFrameGeometry.inset - _CyberFrameGeometry.cornerLen - notch, h - _CyberFrameGeometry.inset)
        ..lineTo(w - _CyberFrameGeometry.inset - _CyberFrameGeometry.cornerLen - notch, h - _CyberFrameGeometry.inset - notch),
      notchPaint,
    );
  }

  void _drawCornerBracket(
    Canvas canvas,
    Offset origin,
    Paint paint, {
    required bool showGlow,
    bool flipX = false,
    bool flipY = false,
  }) {
    const cornerLen = _CyberFrameGeometry.cornerLen;

    final glow = Paint()
      ..color = accentColor.withOpacity(0.5)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(flipX ? -1 : 1, flipY ? -1 : 1);

    if (showGlow) {
      canvas.drawLine(Offset.zero, Offset(cornerLen, 0), glow);
      canvas.drawLine(Offset.zero, Offset(0, cornerLen), glow);
    }
    canvas.drawLine(Offset.zero, Offset(cornerLen, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, cornerLen), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CyberFramePainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.showGlow != showGlow;
  }
}
