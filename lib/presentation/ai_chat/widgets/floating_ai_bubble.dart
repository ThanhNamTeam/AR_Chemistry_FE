import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/storage/ai_fab_storage.dart';
import '../../../shared/styles/app_colors.dart';
import '../providers/ai_fab_visibility.dart';
import 'ai_chat_icon.dart';
import 'ai_chat_modal.dart';

/// Cạnh màn hình mà bong bóng bám vào sau khi thả tay.
enum _BubbleEdge { left, right }

/// Bong bóng chat AI nổi, kiểu bubble Messenger.
///
/// Đặc điểm:
/// - Chỉ hiện icon 56x56 (chuẩn Material FAB), không kèm chữ. Nhãn "Trợ lý AI"
///   chỉ hiện dạng tooltip khi nhấn giữ.
/// - Kéo thả tự do; thả tay thì SNAP về cạnh trái/phải gần nhất.
/// - Kéo lấn qua mép → thu gọn (tuck), chỉ ló ra một nửa; chạm để bung lại.
/// - Vuốt xuống nhanh → ẩn hẳn, thay bằng một tab nhỏ ở mép để gọi lại.
/// - Chạm (khi đang bung) → mở chat bằng đúng logic cũ [AiChatModal.show].
///
/// Widget này phải là con trực tiếp của một [Stack] (nó trả về
/// [AnimatedPositioned]).
class FloatingAiBubble extends StatefulWidget {
  const FloatingAiBubble({super.key});

  /// Đường kính bong bóng — 56dp theo chuẩn Material FAB.
  static const double bubbleSize = 56;

  /// Khoảng hở giữa bong bóng và mép màn hình khi đã snap.
  static const double edgeMargin = 12;

  /// Chừa chỗ cho thanh navigation/bottom bar ở vị trí MẶC ĐỊNH.
  /// (Chỉ áp dụng cho vị trí khởi tạo — người dùng vẫn kéo thấp hơn được.)
  static const double bottomNavReserve = 72;

  /// Phần bong bóng còn ló ra khi đã thu gọn vào mép (0.5 = ló một nửa).
  static const double peekFraction = 0.5;

  /// Kéo lấn qua mép quá ngưỡng này thì mới thu gọn, tránh tuck nhầm.
  static const double tuckThreshold = bubbleSize * 0.35;

  /// Cho phép kéo lấn qua mép tối đa bấy nhiêu (hiệu ứng "đẩy vào cạnh").
  static const double maxOverdrag = bubbleSize * 0.6;

  /// Đường kính vùng "thả để ẩn" (nút X) ở đáy màn hình.
  static const double dismissZoneSize = 64;

  /// Khoảng cách từ đáy (đã trừ safe area) tới TÂM vùng X.
  static const double dismissZoneBottomInset = 96;

  /// Tâm bong bóng vào trong bán kính này thì vùng X "hút" và sáng lên.
  static const double dismissCaptureRadius = 78;

  @override
  State<FloatingAiBubble> createState() => _FloatingAiBubbleState();
}

class _FloatingAiBubbleState extends State<FloatingAiBubble> {
  final _storage = AiFabStorage();

  /// Vị trí góc trên-trái của bong bóng, theo pixel logic.
  Offset? _position;

  /// Vị trí đã lưu dưới dạng tỉ lệ (0..1) để không lệch khi xoay/đổi màn hình.
  Offset? _fraction;

  bool _ready = false;
  bool _dragging = false;

  /// Ẩn hẳn (vuốt xuống). Khi ẩn sẽ hiện tab nhỏ ở mép để gọi lại.
  bool _hidden = false;

  /// Hiện nhãn "Trợ lý AI" cạnh bong bóng khi nhấn giữ (thay cho Tooltip).
  bool _showLabel = false;
  Timer? _labelTimer;

  @override
  void dispose() {
    _labelTimer?.cancel();
    super.dispose();
  }

  /// Nhấn giữ → hiện nhãn ~1.6s rồi tự ẩn.
  void _flashLabel() {
    _labelTimer?.cancel();
    setState(() => _showLabel = true);
    HapticFeedback.selectionClick();
    _labelTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _showLabel = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _restorePosition();
  }

  Future<void> _restorePosition() async {
    final saved = await _storage.loadPosition();
    if (!mounted) return;
    setState(() {
      if (saved != null) _fraction = Offset(saved.x, saved.y);
      _ready = true;
    });
  }

  // ---------------------------------------------------------------------------
  // Các mốc vị trí
  // ---------------------------------------------------------------------------

  /// Giới hạn di chuyển hợp lệ của góc trên-trái bong bóng.
  ///
  /// - `minY` trừ hao `safe.top` để không đè lên status bar.
  /// - `maxY` trừ hao `safe.bottom` để không đè lên navigation bar.
  ({double minX, double maxX, double minY, double maxY}) _bounds(
    Size screen,
    EdgeInsets safe,
  ) {
    const size = FloatingAiBubble.bubbleSize;
    const margin = FloatingAiBubble.edgeMargin;
    return (
      minX: margin,
      maxX: screen.width - size - margin,
      minY: safe.top + margin,
      maxY: screen.height - safe.bottom - size - margin,
    );
  }

  /// Vị trí mặc định: góc PHẢI, phía dưới, nằm trên thanh navigation.
  Offset _defaultPosition(Size screen, EdgeInsets safe) {
    const size = FloatingAiBubble.bubbleSize;
    const margin = FloatingAiBubble.edgeMargin;
    return Offset(
      screen.width - size - margin,
      screen.height -
          safe.bottom -
          FloatingAiBubble.bottomNavReserve -
          size -
          margin,
    );
  }

  /// Vị trí hiện tại: ưu tiên pixel đang kéo → tỉ lệ đã lưu → mặc định.
  Offset _resolvePosition(Size screen, EdgeInsets safe) {
    if (_position != null) return _position!;
    if (_fraction != null) {
      final b = _bounds(screen, safe);
      return Offset(
        b.minX + (b.maxX - b.minX) * _fraction!.dx,
        b.minY + (b.maxY - b.minY) * _fraction!.dy,
      );
    }
    return _defaultPosition(screen, safe);
  }

  /// TÂM của vùng "thả để ẩn" — luôn ở giữa theo chiều ngang, sát đáy
  /// (đã trừ safe area nên không đè lên thanh navigation).
  Offset _dismissZoneCenter(Size screen, EdgeInsets safe) {
    return Offset(
      screen.width / 2,
      screen.height - safe.bottom - FloatingAiBubble.dismissZoneBottomInset,
    );
  }

  /// Bong bóng có đang nằm trong tầm "hút" của vùng X hay không.
  /// Đo bằng khoảng cách giữa TÂM bong bóng và TÂM vùng X.
  bool _isOverDismiss(Offset pos, Size screen, EdgeInsets safe) {
    const half = FloatingAiBubble.bubbleSize / 2;
    final bubbleCenter = Offset(pos.dx + half, pos.dy + half);
    final distance = (bubbleCenter - _dismissZoneCenter(screen, safe)).distance;
    return distance <= FloatingAiBubble.dismissCaptureRadius;
  }

  /// Cạnh gần nhất, xét theo TÂM bong bóng so với đường giữa màn hình.
  _BubbleEdge _nearestEdge(Offset pos, Size screen) {
    final centerX = pos.dx + FloatingAiBubble.bubbleSize / 2;
    return centerX < screen.width / 2 ? _BubbleEdge.left : _BubbleEdge.right;
  }

  /// Toạ độ X sau khi snap.
  ///
  /// - Bình thường: sát mép, chừa [FloatingAiBubble.edgeMargin].
  /// - Đã thu gọn: thụt ra ngoài màn hình, chỉ còn ló
  ///   [FloatingAiBubble.peekFraction] bề rộng.
  double _snappedX(_BubbleEdge edge, Size screen, {required bool tucked}) {
    const size = FloatingAiBubble.bubbleSize;
    const margin = FloatingAiBubble.edgeMargin;
    const peek = size * FloatingAiBubble.peekFraction;

    switch (edge) {
      case _BubbleEdge.left:
        return tucked ? -(size - peek) : margin;
      case _BubbleEdge.right:
        return tucked ? screen.width - peek : screen.width - size - margin;
    }
  }

  // ---------------------------------------------------------------------------
  // Lưu vị trí
  // ---------------------------------------------------------------------------

  Future<void> _persist(Offset pos, Size screen, EdgeInsets safe) async {
    final b = _bounds(screen, safe);
    final spanX = b.maxX - b.minX;
    final spanY = b.maxY - b.minY;
    if (spanX <= 0 || spanY <= 0) return;

    // Chỉ lưu Y theo tỉ lệ + cạnh trái/phải; X luôn được tính lại khi snap
    // nên kẹp về [0,1] là đủ.
    _fraction = Offset(
      ((pos.dx - b.minX) / spanX).clamp(0.0, 1.0),
      ((pos.dy - b.minY) / spanY).clamp(0.0, 1.0),
    );
    await _storage.savePosition(_fraction!.dx, _fraction!.dy);
  }

  // ---------------------------------------------------------------------------
  // Xử lý cử chỉ
  // ---------------------------------------------------------------------------

  void _onPanStart(Offset current) {
    setState(() {
      _dragging = true;
      _position = current;
    });
    HapticFeedback.selectionClick();
  }

  void _onPanUpdate(DragUpdateDetails d, Size screen, EdgeInsets safe) {
    final b = _bounds(screen, safe);
    final next = (_position ?? Offset.zero) + d.delta;
    setState(() {
      _position = Offset(
        // Cho phép lấn qua mép một chút để người dùng "đẩy" bong bóng vào cạnh.
        next.dx.clamp(
          b.minX - FloatingAiBubble.maxOverdrag,
          b.maxX + FloatingAiBubble.maxOverdrag,
        ),
        // Trục dọc thì kẹp cứng — không cho đè status bar / navigation bar.
        next.dy.clamp(b.minY, b.maxY),
      );
    });
  }

  void _onPanEnd(
    DragEndDetails d,
    Size screen,
    EdgeInsets safe,
    AiFabVisibility fab,
  ) {
    final pos = _position;
    if (pos == null) return;

    // (1) Thả trúng vùng X ở đáy màn hình → ẩn hẳn (giống bubble Messenger).
    if (_isOverDismiss(pos, screen, safe)) {
      setState(() {
        _dragging = false;
        _hidden = true;
      });
      HapticFeedback.mediumImpact();
      return;
    }

    final b = _bounds(screen, safe);
    final edge = _nearestEdge(pos, screen);

    // (2) Kéo lấn qua mép đủ sâu → thu gọn vào cạnh.
    final overdrag = switch (edge) {
      _BubbleEdge.left => b.minX - pos.dx,
      _BubbleEdge.right => pos.dx - b.maxX,
    };
    final shouldTuck = overdrag > FloatingAiBubble.tuckThreshold;

    // (3) Snap về cạnh gần nhất, giữ nguyên Y.
    final settled = Offset(
      _snappedX(edge, screen, tucked: shouldTuck),
      pos.dy.clamp(b.minY, b.maxY),
    );

    setState(() {
      _dragging = false;
      _position = settled;
    });

    // Dùng lại provider sẵn có: minimized == đang thu gọn vào mép.
    if (shouldTuck) {
      fab.minimize();
    } else {
      fab.expand();
    }

    HapticFeedback.lightImpact();
    _persist(settled, screen, safe);
  }

  /// Chạm bong bóng: đang thu gọn thì bung ra, đang bung thì mở chat.
  void _onTap(bool tucked, Size screen, EdgeInsets safe, AiFabVisibility fab) {
    if (tucked) {
      final pos = _resolvePosition(screen, safe);
      final edge = _nearestEdge(pos, screen);
      setState(() {
        _position = Offset(_snappedX(edge, screen, tucked: false), pos.dy);
      });
      fab.expand();
      HapticFeedback.selectionClick();
      return;
    }
    // Giữ nguyên logic mở chat cũ.
    AiChatModal.show();
  }

  void _restoreFromHidden() {
    setState(() => _hidden = false);
    HapticFeedback.selectionClick();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();

    final fab = context.watch<AiFabVisibility>();
    final screen = MediaQuery.sizeOf(context);
    final safe = MediaQuery.paddingOf(context);
    final b = _bounds(screen, safe);

    // Đang thu gọn hay không do provider quyết định, nhờ vậy tính năng
    // auto-minimize khi cuộn danh sách vẫn hoạt động như cũ.
    final tucked = fab.isMinimized && !_dragging;

    var pos = _resolvePosition(screen, safe);
    // Khi không kéo, luôn ép bong bóng bám đúng cạnh (kể cả sau khi xoay màn hình).
    if (!_dragging) {
      final edge = _nearestEdge(pos, screen);
      pos = Offset(
        _snappedX(edge, screen, tucked: tucked),
        pos.dy.clamp(b.minY, b.maxY),
      );
    }

    if (_hidden) {
      // Widget này được dùng như con KHÔNG định vị của Stack ngoài
      // (fit: StackFit.expand) nên phải tự phủ kín rồi tự định vị bên trong.
      return Stack(
        clipBehavior: Clip.none,
        children: [
          _RecallTab(
            top: pos.dy,
            screenWidth: screen.width,
            onTap: _restoreFromHidden,
          ),
        ],
      );
    }

    final edge = _nearestEdge(pos, screen);

    // Đang kéo và đã vào tầm hút → vùng X sáng lên và bong bóng bị "hít" vào.
    final overDismiss = _dragging && _isOverDismiss(pos, screen, safe);
    final zoneCenter = _dismissZoneCenter(screen, safe);
    const half = FloatingAiBubble.bubbleSize / 2;
    final renderPos = overDismiss
        ? Offset(zoneCenter.dx - half, zoneCenter.dy - half)
        : pos;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Vùng "thả để ẩn" chỉ xuất hiện trong lúc kéo.
        _DismissZone(
          center: zoneCenter,
          visible: _dragging,
          active: overDismiss,
        ),
        AnimatedPositioned(
          // Đang kéo thì bám ngón tay tức thì; thả ra mới chạy animation snap.
          // Riêng lúc bị hút vào vùng X thì cho animation ngắn cho mượt.
          duration: !_dragging
              ? const Duration(milliseconds: 320)
              : overDismiss
              ? const Duration(milliseconds: 120)
              : Duration.zero,
          curve: Curves.easeOutCubic,
          left: renderPos.dx,
          top: renderPos.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onTap(tucked, screen, safe, fab),
            onLongPress: _flashLabel,
            onPanStart: (_) => _onPanStart(pos),
            onPanUpdate: (d) => _onPanUpdate(d, screen, safe),
            onPanEnd: (d) => _onPanEnd(d, screen, safe, fab),
            child: _BubbleBody(
              dragging: _dragging,
              tucked: tucked,
              edge: edge,
              label: AppLocalizations.of(context).aiAssistant,
              showLabel: _showLabel && !_dragging,
              // Bị hút vào vùng X thì thu nhỏ lại cho thấy sắp bị ẩn.
              overDismiss: overDismiss,
            ),
          ),
        ),
      ],
    );
  }
}

/// Vùng "thả để ẩn" (nút X) ở giữa đáy màn hình, kiểu bubble Messenger.
///
/// Chỉ hiện khi đang kéo bong bóng; khi bong bóng vào tầm hút thì phóng to,
/// sáng lên và đổi màu để báo "thả ra là ẩn".
class _DismissZone extends StatelessWidget {
  const _DismissZone({
    required this.center,
    required this.visible,
    required this.active,
  });

  final Offset center;
  final bool visible;
  final bool active;

  @override
  Widget build(BuildContext context) {
    const size = FloatingAiBubble.dismissZoneSize;
    // Phóng to khi active để tạo cảm giác "hút".
    final scale = active ? 1.25 : 1.0;

    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: AnimatedScale(
            scale: visible ? scale : 0.6,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? const Color(0xFFE53935).withValues(alpha: 0.95)
                    : Colors.black.withValues(alpha: 0.55),
                border: Border.all(
                  color: Colors.white.withValues(alpha: active ? 0.9 : 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (active ? const Color(0xFFE53935) : Colors.black)
                        .withValues(alpha: 0.45),
                    blurRadius: active ? 22 : 10,
                    spreadRadius: active ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: active ? 30 : 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Phần hình tròn của bong bóng (icon AI + đổ bóng).
class _BubbleBody extends StatelessWidget {
  const _BubbleBody({
    required this.dragging,
    required this.tucked,
    required this.edge,
    required this.label,
    required this.showLabel,
    required this.overDismiss,
  });

  final bool dragging;
  final bool tucked;
  final _BubbleEdge edge;
  final String label;
  final bool showLabel;
  final bool overDismiss;

  @override
  Widget build(BuildContext context) {
    const size = FloatingAiBubble.bubbleSize;

    // Stack lấy kích thước theo bong bóng (56x56); nhãn được đặt lệch ra ngoài
    // và vẽ đè nhờ Clip.none — không cần Overlay nên an toàn ở mọi vị trí cây.
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        _bubble(context),
        if (showLabel)
          Positioned(
            // Bong bóng ở mép phải thì nhãn hiện bên trái và ngược lại.
            right: edge == _BubbleEdge.right ? size + 10 : null,
            left: edge == _BubbleEdge.left ? size + 10 : null,
            child: _LabelChip(text: label),
          ),
      ],
    );
  }

  Widget _bubble(BuildContext context) {
    const size = FloatingAiBubble.bubbleSize;

    return AnimatedScale(
      // Bị hút vào vùng X thì thu nhỏ; phóng nhẹ khi kéo; nhỏ nhẹ khi nép mép.
      scale: overDismiss
          ? 0.78
          : dragging
          ? 1.08
          : tucked
          ? 0.94
          : 1.0,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        // Nép vào mép thì mờ bớt cho đỡ chiếm chú ý.
        opacity: tucked ? 0.72 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Semantics(
          // Yêu cầu: bỏ chữ trên nút. Nhãn chỉ dành cho screen reader và
          // cho _LabelChip khi nhấn giữ.
          //
          // KHÔNG dùng Tooltip ở đây: overlay này được gắn trong
          // MaterialApp.builder, tức nằm TRÊN Navigator nên không có Overlay
          // tổ tiên. Tooltip (Flutter 3.10+) dựng bằng OverlayPortal và sẽ
          // throw ngay lúc build -> Flutter thay bằng ErrorWidget đỏ.
          label: label,
          button: true,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: dragging ? 0.50 : 0.34,
                  ),
                  blurRadius: dragging ? 24 : 16,
                  spreadRadius: dragging ? 2 : 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const AiChatIcon(size: size),
          ),
        ),
      ),
    );
  }
}

/// Nhãn "Trợ lý AI" hiện cạnh bong bóng khi nhấn giữ.
///
/// Đây là bản thay thế cho [Tooltip]: overlay AI được gắn trong
/// MaterialApp.builder nên không có Overlay tổ tiên, mà Tooltip lại cần
/// OverlayPortal. Chip này chỉ là widget thường nên dùng được ở mọi nơi.
class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}

/// Tab nhỏ ló ra ở mép phải sau khi người dùng vuốt xuống để ẩn bong bóng.
class _RecallTab extends StatelessWidget {
  const _RecallTab({
    required this.top,
    required this.screenWidth,
    required this.onTap,
  });

  static const double width = 20;
  static const double height = 52;

  final double top;
  final double screenWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      left: screenWidth - width,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.88),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 6,
                offset: const Offset(-2, 2),
              ),
            ],
          ),
          child:
              const Icon(Icons.chevron_left, size: 16, color: AppColors.onGradient),
        ),
      ),
    );
  }
}
