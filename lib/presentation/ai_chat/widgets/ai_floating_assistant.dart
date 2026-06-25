import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/ai_fab_storage.dart';
import '../../../shared/styles/app_colors.dart';
import 'ai_chat_icon.dart';
import 'ai_chat_modal.dart';

/// Nút tròn kiểu đa nhiệm iPhone: chạm mở chat, nhấn giữ + kéo đổi vị trí.
class AiFloatingAssistant extends StatefulWidget {
  const AiFloatingAssistant({super.key});

  static const double fabSize = 58;

  @override
  State<AiFloatingAssistant> createState() => _AiFloatingAssistantState();
}

class _AiFloatingAssistantState extends State<AiFloatingAssistant> {
  final _storage = AiFabStorage();

  Offset? _fraction;
  Offset? _pixelPosition;

  bool _ready = false;
  bool _dragging = false;

  Timer? _longPressTimer;
  Offset? _pointerDownFabPos;
  Offset? _pointerDownGlobal;

  static const _longPressDelay = Duration(milliseconds: 280);
  static const _dragSlop = 6.0;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPosition() async {
    final saved = await _storage.loadPosition();
    if (!mounted) return;
    setState(() {
      if (saved != null) {
        _fraction = Offset(saved.x, saved.y);
      }
      _ready = true;
    });
  }

  Offset _defaultOffset(Size screen, EdgeInsets padding) {
    const margin = 20.0;
    return Offset(
      screen.width - AiFloatingAssistant.fabSize - margin,
      screen.height -
          AiFloatingAssistant.fabSize -
          margin -
          padding.bottom -
          56,
    );
  }

  Offset _resolvePosition(Size screen, EdgeInsets padding) {
    if (_pixelPosition != null) return _pixelPosition!;
    if (_fraction != null) {
      final maxX = screen.width - AiFloatingAssistant.fabSize;
      final maxY = screen.height - AiFloatingAssistant.fabSize;
      return Offset(_fraction!.dx * maxX, _fraction!.dy * maxY);
    }
    return _defaultOffset(screen, padding);
  }

  Offset _clamp(Offset pos, Size screen, EdgeInsets padding) {
    final maxX = screen.width - AiFloatingAssistant.fabSize;
    final maxY = screen.height - AiFloatingAssistant.fabSize;
    return Offset(
      pos.dx.clamp(8.0, maxX - 8),
      pos.dy.clamp(padding.top + 8, maxY - padding.bottom - 8),
    );
  }

  Future<void> _persist(Offset pos, Size screen) async {
    final maxX = screen.width - AiFloatingAssistant.fabSize;
    final maxY = screen.height - AiFloatingAssistant.fabSize;
    if (maxX <= 0 || maxY <= 0) return;
    _fraction = Offset(pos.dx / maxX, pos.dy / maxY);
    _pixelPosition = pos;
    await _storage.savePosition(_fraction!.dx, _fraction!.dy);
  }

  void _beginDrag(Offset fabPos, Size screen, EdgeInsets padding) {
    if (_dragging) return;
    setState(() {
      _dragging = true;
      _pixelPosition = _clamp(fabPos, screen, padding);
    });
    HapticFeedback.mediumImpact();
  }

  void _onPointerDown(
    PointerDownEvent event,
    Offset fabPos,
    Size screen,
    EdgeInsets padding,
  ) {
    _longPressTimer?.cancel();
    _pointerDownFabPos = fabPos;
    _pointerDownGlobal = event.position;

    _longPressTimer = Timer(_longPressDelay, () {
      if (!mounted || _pointerDownGlobal == null) return;
      _beginDrag(fabPos, screen, padding);
    });
  }

  void _onPointerMove(
    PointerMoveEvent event,
    Size screen,
    EdgeInsets padding,
  ) {
    if (_pointerDownGlobal == null || _pointerDownFabPos == null) return;

    final delta = event.position - _pointerDownGlobal!;

    if (!_dragging) {
      if (delta.distance >= _dragSlop) {
        _longPressTimer?.cancel();
        _beginDrag(_pointerDownFabPos!, screen, padding);
      } else {
        return;
      }
    }

    setState(() {
      _pixelPosition = _clamp(_pointerDownFabPos! + delta, screen, padding);
    });
  }

  void _onPointerUp(PointerUpEvent event, Size screen, EdgeInsets padding) {
    _longPressTimer?.cancel();

    final wasDragging = _dragging;
    final finalPos = _pixelPosition ??
        _clamp(_pointerDownFabPos ?? Offset.zero, screen, padding);

    if (wasDragging) {
      _persist(finalPos, screen);
    } else {
      AiChatModal.show();
    }

    setState(() {
      _dragging = false;
      _pointerDownGlobal = null;
      _pointerDownFabPos = null;
    });
  }

  void _onPointerCancel() {
    _longPressTimer?.cancel();
    setState(() {
      _dragging = false;
      _pointerDownGlobal = null;
      _pointerDownFabPos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final pos = _clamp(_resolvePosition(screen, padding), screen, padding);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => _onPointerDown(e, pos, screen, padding),
        onPointerMove: (e) => _onPointerMove(e, screen, padding),
        onPointerUp: (e) => _onPointerUp(e, screen, padding),
        onPointerCancel: (_) => _onPointerCancel(),
        child: _IosStyleFab(dragging: _dragging),
      ),
    );
  }
}

class _IosStyleFab extends StatelessWidget {
  const _IosStyleFab({required this.dragging});

  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: dragging ? 1.12 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Container(
        width: AiFloatingAssistant.fabSize,
        height: AiFloatingAssistant.fabSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: dragging ? 0.55 : 0.38),
              blurRadius: dragging ? 28 : 16,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AiChatIcon(size: AiFloatingAssistant.fabSize),
      ),
    );
  }
}
