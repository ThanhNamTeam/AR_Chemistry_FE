import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/app_portal.dart';
import '../../home/providers/theme_provider.dart';

/// Login header logo with continuous firework around the ring.
class AuthAppLogoBadge extends StatefulWidget {
  const AuthAppLogoBadge({super.key});

  static const _iconSize = 72.0;
  static const _ringPadding = 4.0;
  static const _fireworkDurationMs = 1800;

  @override
  State<AuthAppLogoBadge> createState() => _AuthAppLogoBadgeState();
}

class _AuthAppLogoBadgeState extends State<AuthAppLogoBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fireworkCtrl;
  late final List<_SparkParticle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = _SparkParticle.generate(18);
    _fireworkCtrl = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: AuthAppLogoBadge._fireworkDurationMs),
    )..repeat();
  }

  @override
  void dispose() {
    _fireworkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final option = context.watch<ThemeProvider>().optionFor(AppPortal.auth);
    final isLight = option.key == AppThemeKey.light;
    final primary = option.primary;
    final accent = option.accent;
    final primaryLight = Color.lerp(primary, Colors.white, 0.25)!;
    final totalSize =
        AuthAppLogoBadge._iconSize + AuthAppLogoBadge._ringPadding * 2;

    return SizedBox(
      width: totalSize + 24,
      height: totalSize + 24,
      child: AnimatedBuilder(
        animation: _fireworkCtrl,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(totalSize + 24, totalSize + 24),
                painter: _FireworkPainter(
                  progress: _fireworkCtrl.value,
                  particles: _particles,
                  accentColor: isLight ? primary : primaryLight,
                ),
              ),
              child!,
            ],
          );
        },
        child: Container(
          width: totalSize,
          height: totalSize,
          padding: const EdgeInsets.all(AuthAppLogoBadge._ringPadding),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: 0.2),
                accent.withValues(alpha: 0.2),
              ],
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icon/app_icon.jpg',
              width: AuthAppLogoBadge._iconSize,
              height: AuthAppLogoBadge._iconSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _SparkParticle {
  _SparkParticle({
    required this.angle,
    required this.maxDistance,
    required this.size,
    required this.color,
  });

  final double angle;
  final double maxDistance;
  final double size;
  final Color color;

  static List<_SparkParticle> generate(int count) {
    const palette = [
      Color(0xFF22D3EE),
      Color(0xFF06B6D4),
      Color(0xFF34D399),
      Color(0xFFFBBF24),
      Colors.white,
    ];
    final random = math.Random(7);

    return List.generate(count, (i) {
      return _SparkParticle(
        angle: (math.pi * 2 * i / count) + random.nextDouble() * 0.35,
        maxDistance: 28 + random.nextDouble() * 22,
        size: 2.2 + random.nextDouble() * 2.8,
        color: palette[i % palette.length],
      );
    });
  }
}

class _FireworkPainter extends CustomPainter {
  _FireworkPainter({
    required this.progress,
    required this.particles,
    required this.accentColor,
  });

  final double progress;
  final List<_SparkParticle> particles;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress).clamp(0.0, 1.0);

    for (final p in particles) {
      final dist = p.maxDistance * Curves.easeOut.transform(progress);
      final pos = center +
          Offset(
            math.cos(p.angle) * dist,
            math.sin(p.angle) * dist,
          );

      final glow = Paint()
        ..color = p.color.withValues(alpha: 0.45 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(pos, p.size * 2.2, glow);
      canvas.drawCircle(
        pos,
        p.size * (0.6 + fade * 0.4),
        Paint()..color = p.color.withValues(alpha: fade),
      );
    }

    final burst = Paint()
      ..color = accentColor.withValues(alpha: 0.35 * fade)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawCircle(center, 10 + progress * 18, burst);
  }

  @override
  bool shouldRepaint(covariant _FireworkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
