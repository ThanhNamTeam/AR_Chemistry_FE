import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../routes/app_navigation.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../shared/widgets/knowledge_points_badge.dart';
import '../../home/providers/app_state.dart';
import '../../../domain/models/cart_item_model.dart';
import '../../../domain/models/chemical_card_model.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _showQRModal = false;
  bool _paying = false;

  /// Mã chuyển khoản sinh MỘT LẦN khi mở modal — không được sinh trong build()
  /// vì mỗi rebuild sẽ đổi mã, người dùng quét mã A nhưng app lưu mã B.
  String? _transferCode;

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: error ? AppColors.error : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _payWithPoints(AppState state) async {
    if (_paying) return;
    final l10n = AppLocalizations.of(context);
    final total = state.cartTotalPrice;
    if (state.knowledgePoints < total) {
      _toast(l10n.notEnoughKnowledgePoints, error: true);
      return;
    }
    setState(() => _paying = true);
    try {
      final ok = await state.checkoutCart('points');
      if (!mounted) return;
      if (ok) {
        _toast(l10n.paymentSuccessToast);
        AppNavigation.openMyBag(context);
      } else {
        // Trước đây nhánh lỗi im lặng hoàn toàn — người dùng bấm lại và có
        // nguy cơ trừ điểm hai lần.
        _toast(l10n.paymentFailedToast, error: true);
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _payWithBank() {
    setState(() {
      _transferCode = 'CHEM_${DateTime.now().millisecondsSinceEpoch}';
      _showQRModal = true;
    });
  }

  Future<void> _confirmBank(AppState state) async {
    if (_paying) return;
    setState(() => _paying = true);
    try {
      final ok = await state.checkoutCart('bank');
      if (!mounted) return;
      if (!ok) {
        _toast(AppLocalizations.of(context).paymentFailedToast, error: true);
        return;
      }
      setState(() => _showQRModal = false);
      Navigator.pushNamed(context, AppRoutes.paymentSuccess);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final items = state.cart;
    final total = state.cartTotalPrice;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Icon(Icons.arrow_back,
                                color: AppColors.primary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(l10n.paymentTitle,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Inter')),
                        ),
                        KnowledgePointsBadge(points: state.knowledgePoints),
                      ],
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(l10n.cartEmpty,
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Inter')),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            children: [
                              ...items.map((item) {
                                if (item.type == CartItemType.card) {
                                  final card = state.getCardById(item.id);
                                  if (card == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _CartRow(
                                      title: card.name,
                                      subtitle: card.symbol,
                                      price: state.getCartItemPrice(item),
                                      color: card.color,
                                    ),
                                  );
                                }
                                final bundle = ChemicalData.bundles
                                    .where((b) => b.id == item.id);
                                if (bundle.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                final quote = state.getBundleQuote(item.id);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _CartRow(
                                    title: bundle.first.name,
                                    subtitle:
                                        'Bundle (${quote.remainingCardIds.length} cards)',
                                    price: state.getCartItemPrice(item),
                                    color: AppColors.secondary,
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBg.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(l10n.total,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                            fontFamily: 'Inter')),
                                    Text(l10n.knowledgePoints(total),
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryLight,
                                            fontFamily: 'Inter')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _PayButton(
                          label: l10n.payWithKnowledgePoints,
                          icon: Icons.auto_awesome,
                          gradient: AppColors.amberGradient,
                          loading: _paying,
                          onTap: items.isEmpty || _paying
                              ? null
                              : () => _payWithPoints(state),
                        ),
                        const SizedBox(height: 12),
                        _PayButton(
                          label: l10n.payWithBankVnpay,
                          icon: Icons.credit_card,
                          gradient: AppColors.primaryGradient,
                          loading: false,
                          onTap: items.isEmpty || _paying ? null : _payWithBank,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_showQRModal && _transferCode != null)
                _QRModal(
                  price: total,
                  transferCode: _transferCode!,
                  busy: _paying,
                  onConfirm: () => _confirmBank(state),
                  onCancel: _paying
                      ? null
                      : () => setState(() => _showQRModal = false),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int price;
  final Color color;

  const _CartRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(subtitle,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  fontFamily: 'Inter')),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter')),
          ),
          Text(l10n.knowledgePoints(price),
              style: TextStyle(
                  color: AppColors.amberLight,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

class _PayButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final bool loading;
  final VoidCallback? onTap;

  const _PayButton({
    required this.label,
    required this.icon,
    required this.gradient,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Opacity(
            opacity: onTap == null && !loading ? 0.5 : 1,
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(label,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QRModal extends StatelessWidget {
  final int price;
  final String transferCode;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const _QRModal({
    required this.price,
    required this.transferCode,
    required this.busy,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final qrUrl =
        'https://img.vietqr.io/image/'
        'VCB-1031285717-compact2.png'
        '?amount=$price'
        '&addInfo=$transferCode'
        '&accountName=NGUYEN%20HOAI%20AN';

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.vnpayPayment,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontFamily: 'Inter')),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  qrUrl,
                  width: 220,
                  height: 260,
                  // contain, KHÔNG cover: ảnh VietQR 540x640 bị cover sẽ crop
                  // mất phần chân ghi số tài khoản và số tiền.
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 220,
                      height: 260,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stack) => SizedBox(
                    width: 220,
                    height: 260,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2,
                            size: 48, color: Colors.black26),
                        const SizedBox(height: 8),
                        Text(
                          l10n.qrLoadFailed,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  children: [

                    _InfoRow(
                      l10n.receiver,
                      'NGUYEN HOAI AN',
                    ),

                    const SizedBox(height: 6),

                    _InfoRow(
                      l10n.amount,
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'VND',
                      ).format(price),
                    ),

                    const SizedBox(height: 6),

                    _InfoRow(
                      l10n.transferContent,
                      transferCode,
                      copyable: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: busy ? null : onConfirm,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.confirmPayment),
                ),
              ),
              TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {

  final String label;
  final String value;
  final bool copyable;

  const _InfoRow(
      this.label,
      this.value, {
      this.copyable = false,
      });

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontFamily: 'Inter',
          ),
        ),

        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (copyable)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: AppLocalizations.of(context).copiedToClipboard,
                  icon: const Icon(Icons.copy,
                      size: 16, color: Colors.black54),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context).copiedToClipboard,
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
