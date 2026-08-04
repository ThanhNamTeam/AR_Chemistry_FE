import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'flash_card_face.dart';

/// Displays a flash card with front/back faces and a flip button.
///
/// Uses [frontImageUrl]/[backImageUrl] from API (S3) when available,
/// otherwise [FlashCardFace] placeholder.
class FlashCardFlipView extends StatefulWidget {
  final String substanceFormula;
  final String substanceName;
  final String? frontImageUrl;
  final String? backImageUrl;
  final BorderRadius borderRadius;

  const FlashCardFlipView({
    super.key,
    required this.substanceFormula,
    required this.substanceName,
    this.frontImageUrl,
    this.backImageUrl,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<FlashCardFlipView> createState() => _FlashCardFlipViewState();
}

class _FlashCardFlipViewState extends State<FlashCardFlipView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() => _showFront = !_showFront);
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * math.pi;
              final isFrontVisible = angle <= math.pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: isFrontVisible
                    ? _buildFace(showFront: _showFront)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: _buildFace(showFront: !_showFront),
                      ),
              );
            },
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: _flip,
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.flip_camera_android_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFace({required bool showFront}) {
    final url = showFront ? widget.frontImageUrl : widget.backImageUrl;
    final fallback = _codedFace(showFront);

    if (url != null && url.trim().isNotEmpty) {
      return _NetworkFace(
        url: url.trim(),
        fallback: fallback,
      );
    }

    return fallback;
  }

  Widget _codedFace(bool showFront) {
    return FlashCardFace(
      side: showFront ? FlashCardSide.front : FlashCardSide.back,
      formula: widget.substanceFormula,
      name: widget.substanceName,
    );
  }
}

class _NetworkFace extends StatelessWidget {
  final String url;
  final Widget fallback;

  const _NetworkFace({
    required this.url,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return fallback;
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Stack(
            fit: StackFit.expand,
            children: [
              fallback,
              Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: const Color(0xFF1F5C38),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
