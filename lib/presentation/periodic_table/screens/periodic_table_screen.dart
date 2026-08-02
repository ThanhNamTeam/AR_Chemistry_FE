import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api/ar_access_api.dart';
import '../../../core/data/periodic_elements.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';

/// Bảng tuần hoàn tương tác — dữ liệu tĩnh, không cần backend.
///
/// - Ô màu theo phân loại nguyên tố, chú giải ở đầu trang.
/// - Nguyên tố có thẻ AR trong bộ LABEDU được viền cam + icon AR, chạm vào có
///   nút nhảy thẳng sang máy quét.
/// - Tìm kiếm theo ký hiệu hoặc tên tiếng Việt: ô không khớp bị làm mờ.
/// - Toàn bảng đặt trong [InteractiveViewer] để véo-zoom và kéo tự do.
class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  State<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen> {
  static const double _cellW = 64;
  static const double _cellH = 76;
  static const double _gap = 4;
  static const double _fBlockSpacing = 18;

  final _searchCtrl = TextEditingController();
  final ArAccessApi _arAccessApi = ArAccessApi();

  String _query = '';
  ElementCategory? _categoryFilter;
  bool _checkingArAccess = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static Color categoryColor(ElementCategory c) => switch (c) {
        ElementCategory.alkaliMetal => const Color(0xFFEF4444),
        ElementCategory.alkalineEarth => const Color(0xFFF97316),
        ElementCategory.transitionMetal => const Color(0xFFEAB308),
        ElementCategory.postTransition => const Color(0xFF22C55E),
        ElementCategory.metalloid => const Color(0xFF14B8A6),
        ElementCategory.nonmetal => const Color(0xFF06B6D4),
        ElementCategory.halogen => const Color(0xFF3B82F6),
        ElementCategory.nobleGas => const Color(0xFF8B5CF6),
        ElementCategory.lanthanide => const Color(0xFFEC4899),
        ElementCategory.actinide => const Color(0xFFA855F7),
        ElementCategory.unknown => const Color(0xFF64748B),
      };

  bool _matches(PeriodicElement e) {
    if (_categoryFilter != null && e.category != _categoryFilter) return false;
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return e.symbol.toLowerCase().contains(q) ||
        e.viName.toLowerCase().contains(q) ||
        e.number.toString() == q;
  }

  // ---------------------------------------------------------------------------
  // Vị trí ô trong lưới 18 cột. Họ Lantan/Actini xếp 2 hàng riêng bên dưới.
  // ---------------------------------------------------------------------------

  Offset _cellPosition(PeriodicElement e) {
    const stride = _cellW + _gap;
    const strideY = _cellH + _gap;

    if (e.group != null) {
      return Offset((e.group! - 1) * stride, (e.period - 1) * strideY);
    }
    // f-block: La(57)-Lu(71) hàng 8, Ac(89)-Lr(103) hàng 9, cột 4-18.
    final isLanthanide = e.number >= 57 && e.number <= 71;
    final indexInRow = isLanthanide ? e.number - 57 : e.number - 89;
    final row = isLanthanide ? 7 : 8;
    return Offset(
      (3 + indexInRow) * stride,
      row * strideY + _fBlockSpacing,
    );
  }

  double get _tableWidth => 18 * (_cellW + _gap) - _gap;
  double get _tableHeight => 9 * (_cellH + _gap) + _fBlockSpacing - _gap;

  // ---------------------------------------------------------------------------
  // AR
  // ---------------------------------------------------------------------------

  /// Cùng luồng kiểm tra quyền AR như nút trên Home: không có quyền thì mời
  /// kích hoạt/mua gói thay vì cho vào thẳng máy quét.
  Future<void> _openArScanner() async {
    if (_checkingArAccess) return;
    setState(() => _checkingArAccess = true);
    final l10n = AppLocalizations.of(context);

    try {
      final access = await _arAccessApi.getMyArAccess();
      if (!mounted) return;

      if (access.canScanAR) {
        Navigator.pop(context); // đóng bottom sheet
        Navigator.pushNamed(context, AppRoutes.arAssetLoading);
      } else {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRoutes.packages);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.arAccessCheckFailed),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingArAccess = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(l10n),
              _buildSearch(l10n),
              _buildLegend(),
              const SizedBox(height: 8),
              Expanded(child: _buildTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l10n.back,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child:
                    Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.periodicTableTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.view_in_ar, size: 14, color: AppColors.amberLight),
                const SizedBox(width: 4),
                Text(
                  '${arElementSymbols.length} AR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textAmber,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v.trim()),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Inter',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: l10n.periodicSearchHint,
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontFamily: 'Inter',
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.clear,
                      size: 18, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
          isDense: true,
          filled: true,
          fillColor: AppColors.cardSurfaceMuted,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: ElementCategory.values.map((c) {
          final selected = _categoryFilter == c;
          final color = categoryColor(c);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              button: true,
              selected: selected,
              label: c.viName,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(
                  () => _categoryFilter = selected ? null : c,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: selected ? 0.35 : 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: selected ? 0.9 : 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        c.viName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable() {
    return InteractiveViewer(
      constrained: false,
      minScale: 0.4,
      maxScale: 3,
      boundaryMargin: const EdgeInsets.all(60),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SizedBox(
          width: _tableWidth,
          height: _tableHeight,
          child: Stack(
            children: [
              _fBlockMarker(period: 6, label: '57–71',
                  color: categoryColor(ElementCategory.lanthanide)),
              _fBlockMarker(period: 7, label: '89–103',
                  color: categoryColor(ElementCategory.actinide)),
              for (final e in periodicElements) _buildCell(e),
            ],
          ),
        ),
      ),
    );
  }

  /// Ô đánh dấu "57–71" / "89–103" tại cột 3 của chu kỳ 6/7.
  Widget _fBlockMarker({
    required int period,
    required String label,
    required Color color,
  }) {
    return Positioned(
      left: 2 * (_cellW + _gap),
      top: (period - 1) * (_cellH + _gap),
      child: Container(
        width: _cellW,
        height: _cellH,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(PeriodicElement e) {
    final pos = _cellPosition(e);
    final color = categoryColor(e.category);
    final hasAr = arElementSymbols.contains(e.symbol);
    final dimmed = !_matches(e);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: Opacity(
        opacity: dimmed ? 0.18 : 1,
        child: Semantics(
          button: true,
          label: '${e.viName}, ${e.symbol}, số hiệu ${e.number}',
          child: GestureDetector(
            onTap: () => _showElementSheet(e),
            child: Container(
              width: _cellW,
              height: _cellH,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: AppColors.isLight ? 0.14 : 0.16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasAr
                      ? AppColors.amberLight
                      : color.withValues(alpha: 0.5),
                  width: hasAr ? 1.6 : 1,
                ),
                boxShadow: hasAr
                    ? [
                        BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${e.number}',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const Spacer(),
                      if (hasAr)
                        Icon(Icons.view_in_ar,
                            size: 9, color: AppColors.amberLight),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          e.symbol,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    e.viName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 7.5,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Chi tiết nguyên tố
  // ---------------------------------------------------------------------------

  void _showElementSheet(PeriodicElement e) {
    final l10n = AppLocalizations.of(context);
    final color = categoryColor(e.category);
    final hasAr = arElementSymbols.contains(e.symbol);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 20, 24, 24 + MediaQuery.paddingOf(ctx).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.35),
                          color.withValues(alpha: 0.12),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: color.withValues(alpha: 0.6)),
                    ),
                    child: Center(
                      child: Text(
                        e.symbol,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.viName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: color.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            e.category.viName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${e.number}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _infoRow(l10n.atomicMassLabel, e.mass),
              _infoRow(
                l10n.electronegativityLabel,
                e.electronegativity?.toStringAsFixed(2) ?? '—',
              ),
              _infoRow(l10n.electronConfigLabel, e.electronConfig),
              _infoRow(l10n.periodLabel, '${e.period}'),
              _infoRow(
                l10n.groupLabel,
                e.group?.toString() ??
                    (e.category == ElementCategory.lanthanide
                        ? l10n.lanthanideRowLabel
                        : l10n.actinideRowLabel),
              ),
              if (hasAr) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.view_in_ar,
                          color: AppColors.amberLight, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.arCardAvailable,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _checkingArAccess
                        ? null
                        : () async {
                            setSheetState(() {});
                            await _openArScanner();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: _checkingArAccess
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.qr_code_scanner, size: 18),
                    label: Text(l10n.scanArCard),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
