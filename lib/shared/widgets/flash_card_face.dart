import 'package:flutter/material.dart';

enum FlashCardSide { front, back }

/// Programmatic flash card face (FE placeholder until BE provides S3 URLs).
class FlashCardFace extends StatelessWidget {
  final FlashCardSide side;
  final String formula;
  final String name;

  const FlashCardFace({
    super.key,
    required this.side,
    required this.formula,
    required this.name,
  });

  static const _green = Color(0xFF1F5C38);
  static const _greenLight = Color(0xFF3D8B5E);
  static const _cream = Color(0xFFF4F0E6);
  static const _orange = Color(0xFFE8872B);

  /// Bề rộng thiết kế chuẩn. Nội dung luôn được dựng ở cỡ này rồi FittedBox
  /// scale xuống khung thật — font/icon cố định sẽ không bao giờ tràn khi card
  /// bị render ở ô nhỏ (ví dụ preview 114x62 trong journey carousel).
  static const double _refWidth = 240;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBounds = constraints.maxWidth.isFinite &&
                constraints.maxHeight.isFinite &&
                constraints.maxWidth > 0 &&
                constraints.maxHeight > 0;

            final content = Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _GridPainter()),
                ..._decorations(),
                if (side == FlashCardSide.front)
                  _buildFront()
                else
                  _buildBack(),
              ],
            );

            if (!hasBounds) return content;

            final refHeight =
                _refWidth * constraints.maxHeight / constraints.maxWidth;

            return FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: _refWidth,
                height: refHeight,
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _decorations() {
    return [
      Positioned(
        top: 12,
        left: 14,
        child: _dotPair(),
      ),
      Positioned(
        top: 12,
        right: 14,
        child: _dotPair(),
      ),
      Positioned(
        bottom: 36,
        left: 14,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _greenLight.withValues(alpha: 0.35)),
          ),
          child: Icon(
            Icons.hexagon_outlined,
            size: 16,
            color: _greenLight.withValues(alpha: 0.45),
          ),
        ),
      ),
    ];
  }

  Widget _buildFront() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            formula,
            style: const TextStyle(
              color: _green,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const Spacer(flex: 2),
          Center(
            child: Text(
              formula,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _green,
                fontSize: formula.length > 4 ? 34 : 46,
                fontWeight: FontWeight.w900,
                fontFamily: 'Inter',
                height: 1,
              ),
            ),
          ),
          const Spacer(flex: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _green,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.science_outlined,
                color: _greenLight.withValues(alpha: 0.55),
                size: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _backTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.biotech_outlined,
                        size: 36,
                        color: _greenLight.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formula,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _green,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _green.withValues(alpha: 0.75),
                          fontSize: 10,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _green, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size.square(80),
                            painter: _QrPlaceholderPainter(),
                          ),
                          Text(
                            formula.length > 3
                                ? formula.substring(0, 3)
                                : formula,
                            style: const TextStyle(
                              color: _green,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              'AR Chemistry Visual',
              style: TextStyle(
                color: _green.withValues(alpha: 0.45),
                fontSize: 8,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _backTitle {
    final isCompound = formula.length > 2 ||
        RegExp(r'\d').hasMatch(formula) ||
        formula != formula.toUpperCase();
    if (isCompound) return 'Compound: $name';
    return 'Element: $name';
  }

  Widget _dotPair() {
    return Column(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: _orange,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: _greenLight.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F5C38).withValues(alpha: 0.06)
      ..strokeWidth = 0.5;

    const step = 14.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QrPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F5C38).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    const cell = 5.0;
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        if ((row + col) % 2 == 0 && !(row > 2 && row < 5 && col > 2 && col < 5)) {
          canvas.drawRect(
            Rect.fromLTWH(col * cell + 4, row * cell + 4, cell - 1, cell - 1),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
