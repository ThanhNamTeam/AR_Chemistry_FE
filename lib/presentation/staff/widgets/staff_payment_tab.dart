import 'package:flutter/material.dart';

import '../../../core/api/payment_api.dart';
import '../../../core/models/response/payment_response.dart';
import '../../../shared/styles/app_colors.dart';
import '../../shared/widgets/portal/portal_widgets.dart';

class StaffPaymentTab extends StatefulWidget {
  const StaffPaymentTab({super.key});

  @override
  State<StaffPaymentTab> createState() => _StaffPaymentTabState();
}

class _StaffPaymentTabState extends State<StaffPaymentTab> {
  final PaymentApi _paymentApi = PaymentApi();

  bool _loading = false;
  String? _error;
  List<PaymentResponse> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await _paymentApi.getPaymentsForStaff();
      setState(() {
        _payments = page.items;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _approvePayment(String paymentId) async {
    try {
      await _paymentApi.approvePayment(paymentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Duyệt thanh toán thành công'),
        ),
      );

      await _loadPayments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Duyệt thất bại: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_payments.isEmpty) {
      return const PortalEmptyState(
        icon: Icons.payments_outlined,
        title: 'Chưa có thanh toán',
        subtitle: 'Danh sách thanh toán sẽ hiển thị ở đây.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: _payments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final payment = _payments[index];

          return PortalGlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        payment.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    _StatusBadge(status: payment.status),
                  ],
                ),
                const SizedBox(height: 12),

                _InfoRow(
                  label: 'Gói',
                  value: payment.packageName,
                ),
                _InfoRow(
                  label: 'Số tiền',
                  value: '${payment.amount}',
                ),
                _InfoRow(
                  label: 'Mã thanh toán',
                  value: payment.id,
                ),

                if (payment.proofImageUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      payment.proofImageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 120,
                        alignment: Alignment.center,
                        color: AppColors.primary.withValues(alpha: 0.08),
                        child: const Text('Không tải được ảnh minh chứng'),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: payment.status.toUpperCase() == 'APPROVED'
                        ? null
                        : () => _approvePayment(payment.id),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Duyệt thanh toán'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 95,
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
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = status.toUpperCase() == 'APPROVED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isApproved
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isApproved ? AppColors.success : AppColors.amber,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}