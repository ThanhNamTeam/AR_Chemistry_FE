import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/navigation/app_navigator.dart';
import '../../../core/storage/ai_fab_storage.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/ai_fab_visibility.dart';
import 'ai_chat_icon.dart';
import 'ai_chat_modal.dart';

/// Nút AI nổi: expanded (64px + label) / minimized (48px sparkle).
/// Tap minimized → expand; tap expanded → mở chat; kéo xuống → thu gọn.
class AiFloatingAssistant extends StatefulWidget {
  const AiFloatingAssistant({super.key});

  static const double expandedSize = 64;
  static const double minimizedSize = 48;
  static const double labelGap = 6;
  static const Color minimizedColor = Color(0xFF0EA5E9);

  static double heightForMode(AiFabDisplayMode mode) {
    switch (mode) {
      case AiFabDisplayMode.expanded:
        return expandedSize + labelGap + 18;
      case AiFabDisplayMode.minimized:
        return minimizedSize;
    }
  }

  static double widthForMode(AiFabDisplayMode mode) {
    switch (mode) {
      case AiFabDisplayMode.expanded:
        return expandedSize;
      case AiFabDisplayMode.minimized:
        return minimizedSize;
    }
  }

  @override
  State<AiFloatingAssistant> createState() => _AiFloatingAssistantState();
}

class _AiFloatingAssistantState extends State<AiFloatingAssistant> {
  final _storage = AiFabStorage();

  Offset? _fraction;
  Offset? _pixelPosition;

  bool _ready = false;
  bool _dragging = false;
  bool _swipeDownDismiss = false;

  Timer? _longPressTimer;
  Offset? _pointerDownFabPos;
  Offset? _pointerDownGlobal;

  static const _longPressDelay = Duration(milliseconds: 280);
  static const _dragSlop = 6.0;
  static const _swipeDownThreshold = 48.0;

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

  double _fabWidth(AiFabDisplayMode mode) =>
      AiFloatingAssistant.widthForMode(mode);

  double _fabHeight(AiFabDisplayMode mode) =>
      AiFloatingAssistant.heightForMode(mode);

  Offset _defaultOffset(
    Size screen,
    EdgeInsets padding,
    AiFabDisplayMode mode,
  ) {
    const margin = 20.0;
    final w = _fabWidth(mode);
    final h = _fabHeight(mode);
    return Offset(
      screen.width - w - margin,
      screen.height - h - margin - padding.bottom - 56,
    );
  }

  Offset _resolvePosition(
    Size screen,
    EdgeInsets padding,
    AiFabDisplayMode mode,
  ) {
    final w = _fabWidth(mode);
    final h = _fabHeight(mode);
    if (_pixelPosition != null) return _pixelPosition!;
    if (_fraction != null) {
      final maxX = screen.width - w;
      final maxY = screen.height - h;
      return Offset(_fraction!.dx * maxX, _fraction!.dy * maxY);
    }
    return _defaultOffset(screen, padding, mode);
  }

  double _bottomReserve(AiFabDisplayMode mode) {
    final route = AppNavigator.currentRouteName;
    if (route == AppRoutes.shop && mode == AiFabDisplayMode.expanded) {
      return 100;
    }
    return 0;
  }

  Offset _clamp(
    Offset pos,
    Size screen,
    EdgeInsets padding,
    AiFabDisplayMode mode,
  ) {
    final w = _fabWidth(mode);
    final h = _fabHeight(mode);
    final maxX = screen.width - w;
    final maxY = screen.height - h - _bottomReserve(mode);
    return Offset(
      pos.dx.clamp(8.0, maxX - 8),
      pos.dy.clamp(padding.top + 8, maxY - padding.bottom - 8),
    );
  }

  Future<void> _persist(Offset pos, Size screen, AiFabDisplayMode mode) async {
    final w = _fabWidth(mode);
    final h = _fabHeight(mode);
    final maxX = screen.width - w;
    final maxY = screen.height - h;
    if (maxX <= 0 || maxY <= 0) return;
    _fraction = Offset(pos.dx / maxX, pos.dy / maxY);
    _pixelPosition = pos;
    await _storage.savePosition(_fraction!.dx, _fraction!.dy);
  }

  void _beginDrag(Offset fabPos, Size screen, EdgeInsets padding, AiFabDisplayMode mode) {
    if (_dragging) return;
    setState(() {
      _dragging = true;
      _swipeDownDismiss = false;
      _pixelPosition = _clamp(fabPos, screen, padding, mode);
    });
    HapticFeedback.mediumImpact();
  }

  void _onPointerDown(
    PointerDownEvent event,
    Offset fabPos,
    Size screen,
    EdgeInsets padding,
    AiFabDisplayMode mode,
  ) {
    _longPressTimer?.cancel();
    _pointerDownFabPos = fabPos;
    _pointerDownGlobal = event.position;
    _swipeDownDismiss = false;

    _longPressTimer = Timer(_longPressDelay, () {
      if (!mounted || _pointerDownGlobal == null) return;
      _beginDrag(fabPos, screen, padding, mode);
    });
  }

  void _onPointerMove(
    PointerMoveEvent event,
    Size screen,
    EdgeInsets padding,
    AiFabDisplayMode mode,
    AiFabVisibility fabState,
  ) {
    if (_pointerDownGlobal == null || _pointerDownFabPos == null) return;

    final delta = event.position - _pointerDownGlobal!;

    if (!_dragging &&
        mode == AiFabDisplayMode.expanded &&
        delta.dy > _swipeDownThreshold &&
        delta.dy > delta.dx.abs() * 1.2) {
      _swipeDownDismiss = true;
    }

    if (!_dragging) {
      if (delta.distance >= _dragSlop) {
        _longPressTimer?.cancel();
        _beginDrag(_pointerDownFabPos!, screen, padding, mode);
      } else {
        return;
      }
    }

    setState(() {
      _pixelPosition = _clamp(_pointerDownFabPos! + delta, screen, padding, mode);
    });
  }

  void _onPointerUp(
    PointerUpEvent event,
    Size screen,
    EdgeInsets padding,
    AiFabVisibility fabState,
    AiFabDisplayMode mode,
  ) {
    _longPressTimer?.cancel();

    final wasDragging = _dragging;
    final finalPos = _pixelPosition ??
        _clamp(_pointerDownFabPos ?? Offset.zero, screen, padding, mode);

    if (wasDragging) {
      _persist(finalPos, screen, mode);
    } else if (_swipeDownDismiss && mode == AiFabDisplayMode.expanded) {
      fabState.minimize();
      HapticFeedback.lightImpact();
    } else if (mode == AiFabDisplayMode.minimized) {
      fabState.expand();
      HapticFeedback.selectionClick();
    } else {
      AiChatModal.show();
    }

    setState(() {
      _dragging = false;
      _swipeDownDismiss = false;
      _pointerDownGlobal = null;
      _pointerDownFabPos = null;
    });
  }

  void _onPointerCancel() {
    _longPressTimer?.cancel();
    setState(() {
      _dragging = false;
      _swipeDownDismiss = false;
      _pointerDownGlobal = null;
      _pointerDownFabPos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    final fabState = context.watch<AiFabVisibility>();
    final mode = fabState.displayMode;
    final l10n = AppLocalizations.of(context);

    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final pos = _clamp(_resolvePosition(screen, padding, mode), screen, padding, mode);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => _onPointerDown(e, pos, screen, padding, mode),
        onPointerMove: (e) =>
            _onPointerMove(e, screen, padding, mode, fabState),
        onPointerUp: (e) => _onPointerUp(e, screen, padding, fabState, mode),
        onPointerCancel: (_) => _onPointerCancel(),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: mode == AiFabDisplayMode.minimized
              ? _MinimizedFab(
                  key: const ValueKey('minimized'),
                  dragging: _dragging,
                )
              : _ExpandedFab(
                  key: const ValueKey('expanded'),
                  dragging: _dragging,
                  label: l10n.aiAssistant,
                ),
        ),
      ),
    );
  }
}

class _ExpandedFab extends StatelessWidget {
  const _ExpandedFab({
    super.key,
    required this.dragging,
    required this.label,
  });

  final bool dragging;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: dragging ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AiFloatingAssistant.expandedSize,
            height: AiFloatingAssistant.expandedSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: dragging ? 0.55 : 0.42),
                  blurRadius: dragging ? 28 : 20,
                  spreadRadius: dragging ? 2 : 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: AiChatIcon(size: AiFloatingAssistant.expandedSize),
          ),
          const SizedBox(height: AiFloatingAssistant.labelGap),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withValues(alpha: 0.92),
              fontFamily: 'Inter',
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimizedFab extends StatelessWidget {
  const _MinimizedFab({
    super.key,
    required this.dragging,
  });

  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: dragging ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Container(
        width: AiFloatingAssistant.minimizedSize,
        height: AiFloatingAssistant.minimizedSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AiFloatingAssistant.minimizedColor,
          boxShadow: [
            BoxShadow(
              color: AiFloatingAssistant.minimizedColor.withValues(alpha: 0.45),
              blurRadius: dragging ? 16 : 12,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
