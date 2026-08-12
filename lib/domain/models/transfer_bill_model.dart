/// Kỳ lọc biểu đồ doanh thu chuyển khoản (dashboard admin).
enum RevenueFilterPeriod { day, month, year }

/// Bill chuyển khoản mock (từ ảnh trong `doanhthuAR/`).
class TransferBill {
  final int stt;
  final String? transactionId;
  final DateTime transferredAt;
  final String recipientName;
  final String accountNumber;
  final String bank;
  final int amountVnd;
  final String? message;
  final String? receiptAsset;

  const TransferBill({
    required this.stt,
    required this.transactionId,
    required this.transferredAt,
    required this.recipientName,
    required this.accountNumber,
    required this.bank,
    required this.amountVnd,
    required this.message,
    this.receiptAsset,
  });

  /// [notShown] nên lấy từ l10n (VI/EN), không hardcode tiếng Việt.
  String transactionIdDisplay(String notShown) =>
      (transactionId == null || transactionId!.isEmpty)
          ? notShown
          : transactionId!;

  String messageDisplay(String notShown) =>
      (message == null || message!.isEmpty) ? notShown : message!;

  String get amountDisplay {
    final s = amountVnd.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return '$buf VND';
  }

  String get timeDisplay {
    final d = transferredAt;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final ss = d.second;
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (ss == 0) return '$hh:$mm - $date';
    return '$hh:$mm:${ss.toString().padLeft(2, '0')} - $date';
  }
}
