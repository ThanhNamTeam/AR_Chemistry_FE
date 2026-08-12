import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../data/admin/transfer_bills_catalog.dart';
import '../../../domain/models/transfer_bill_model.dart';
import '../../../shared/styles/app_colors.dart';
import '../../home/providers/theme_provider.dart';
import '../../shared/widgets/portal/portal_widgets.dart';

/// Tab Doanh thu — danh sách bill chuyển khoản, 10 hàng / trang.
class AdminRevenueTab extends StatefulWidget {
  const AdminRevenueTab({super.key});

  @override
  State<AdminRevenueTab> createState() => _AdminRevenueTabState();
}

class _AdminRevenueTabState extends State<AdminRevenueTab> {
  static const _pageSize = 10;
  int _page = 0;

  List<TransferBill> get _all => TransferBillsCatalog.sortedNewestFirst;

  int get _totalPages {
    if (_all.isEmpty) return 1;
    return ((_all.length - 1) ~/ _pageSize) + 1;
  }

  List<TransferBill> get _pageItems {
    final start = _page * _pageSize;
    if (start >= _all.length) return const [];
    final end = (start + _pageSize).clamp(0, _all.length);
    return _all.sublist(start, end);
  }

  String _vnd(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M ₫';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K ₫';
    return '$v ₫';
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild khi đổi theme / ngôn ngữ (IndexedStack + const page).
    context.watch<ThemeProvider>();
    context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context);
    final items = _pageItems;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        PortalSectionHeader(title: l10n.navRevenue),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: PortalStatCard(
                icon: Icons.receipt_long_outlined,
                label: l10n.revenueBillCount,
                value: '${_all.length}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PortalStatCard(
                icon: Icons.payments_outlined,
                label: l10n.revenueTotal,
                value: _vnd(TransferBillsCatalog.totalAmountVnd),
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BillCard(bill: b, l10n: l10n),
            )),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                l10n.revenueEmpty,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        _PaginationBar(
          page: _page,
          totalPages: _totalPages,
          totalItems: _all.length,
          pageSize: _pageSize,
          l10n: l10n,
          onPrev: _page > 0 ? () => setState(() => _page--) : null,
          onNext:
              _page < _totalPages - 1 ? () => setState(() => _page++) : null,
        ),
      ],
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.bill, required this.l10n});

  final TransferBill bill;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return PortalGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${bill.stt}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  bill.amountDisplay,
                  style: TextStyle(
                    color: AppColors.emphasisPositive,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (bill.receiptAsset != null)
                IconButton(
                  tooltip: l10n.revenueViewReceipt,
                  onPressed: () => _showReceipt(context, bill),
                  icon: Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _row(
            l10n.revenueColTxnId,
            bill.transactionIdDisplay(l10n.revenueNotShown),
          ),
          _row(l10n.revenueColTime, bill.timeDisplay),
          _row(l10n.revenueColRecipient, bill.recipientName),
          _row(l10n.revenueColAccount, bill.accountNumber),
          _row(l10n.revenueColBank, bill.bank),
          _row(
            l10n.revenueColMessage,
            bill.messageDisplay(l10n.revenueNotShown),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
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
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipt(BuildContext context, TransferBill bill) {
    final asset = bill.receiptAsset;
    if (asset == null) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.cardBg,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.revenueViewReceipt} #${bill.stt}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.revenueReceiptMissing,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.l10n,
    required this.onPrev,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final AppLocalizations l10n;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final from = totalItems == 0 ? 0 : page * pageSize + 1;
    final to = ((page + 1) * pageSize).clamp(0, totalItems);

    return PortalGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.revenuePageLabel(from, to, totalItems),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            color: onPrev == null
                ? AppColors.textSecondary.withValues(alpha: 0.4)
                : AppColors.primary,
          ),
          Text(
            '${page + 1} / $totalPages',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: onNext == null
                ? AppColors.textSecondary.withValues(alpha: 0.4)
                : AppColors.primary,
          ),
        ],
      ),
    );
  }
}
