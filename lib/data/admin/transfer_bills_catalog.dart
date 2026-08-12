import '../../domain/models/transfer_bill_model.dart';

/// Mock 20 bill chuyển khoản (data từ `doanhthuAR/`).
class TransferBillsCatalog {
  TransferBillsCatalog._();

  static TransferBill _b({
    required int stt,
    required String? transactionId,
    required DateTime at,
    required String? message,
    String bank = 'Vietcombank',
  }) {
    return TransferBill(
      stt: stt,
      transactionId: transactionId,
      transferredAt: at,
      recipientName: 'NGUYEN HOAI AN',
      accountNumber: '1031285717',
      bank: bank,
      amountVnd: 139000,
      message: message,
      receiptAsset: 'doanhthuAR/$stt.jpg',
    );
  }

  static final List<TransferBill> all = [
    _b(
      stt: 1,
      transactionId: '15536339362',
      at: DateTime(2026, 8, 11, 21, 8),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 2,
      transactionId: '2585061859',
      at: DateTime(2026, 8, 12, 11, 50, 4),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 3,
      transactionId: '141861234647',
      at: DateTime(2026, 8, 12, 10, 59),
      message: null,
    ),
    _b(
      stt: 4,
      transactionId: '15542263776',
      at: DateTime(2026, 8, 12, 10, 57),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 5,
      transactionId: '141860297660',
      at: DateTime(2026, 8, 12, 10, 53),
      message: null,
    ),
    _b(
      stt: 6,
      transactionId: null,
      at: DateTime(2026, 8, 8, 13, 37),
      message: 'LABEDU AR30',
      bank: 'Vietcombank (VCB)',
    ),
    _b(
      stt: 7,
      transactionId: '15480119572',
      at: DateTime(2026, 8, 8, 14, 37),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 8,
      transactionId: '020097048808081641542026xtmy452100',
      at: DateTime(2026, 8, 8, 16, 41, 47),
      message: 'LABEDU AR30',
      bank: 'Vietcombank (VCB)',
    ),
    _b(
      stt: 9,
      transactionId: '2644',
      at: DateTime(2026, 8, 8, 18, 18, 15),
      message: 'LABEDU AR30-080826-18:18:15 6220ASCB02TSWN6V',
    ),
    _b(
      stt: 10,
      transactionId: '15492877014',
      at: DateTime(2026, 8, 9, 11, 41),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 11,
      transactionId: '924K2680HF3JQ609',
      at: DateTime(2026, 8, 11, 21, 30),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 12,
      transactionId: '141798558972',
      at: DateTime(2026, 8, 11, 21, 28),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 13,
      transactionId: '15536339362',
      at: DateTime(2026, 8, 11, 21, 8),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 14,
      transactionId: null,
      at: DateTime(2026, 8, 11, 21, 7),
      message: 'LABEDU AR30',
      bank: 'Vietcombank (VCB)',
    ),
    _b(
      stt: 15,
      transactionId: '664V60026223AGWV - 6223TPBVI2CMLXVI',
      at: DateTime(2026, 8, 11, 21, 4),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 16,
      transactionId: '15536252346',
      at: DateTime(2026, 8, 11, 21, 2),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 17,
      transactionId: '141795215501',
      at: DateTime(2026, 8, 11, 21, 2),
      message: null,
    ),
    _b(
      stt: 18,
      transactionId: '15540765944',
      at: DateTime(2026, 8, 12, 9, 15),
      message: 'LABEDU AR30',
    ),
    _b(
      stt: 19,
      transactionId: null,
      at: DateTime(2026, 8, 9, 12, 1),
      message: 'LABEDU AR30',
      bank: 'Vietcombank (VCB)',
    ),
    _b(
      stt: 20,
      transactionId: null,
      at: DateTime(2026, 8, 9, 11, 55),
      message: 'LABEDU AR30',
      bank: 'Vietcombank (VCB)',
    ),
  ];

  /// Sắp xếp mới nhất trước (cho list tab Doanh thu).
  static List<TransferBill> get sortedNewestFirst {
    final copy = List<TransferBill>.from(all);
    copy.sort((a, b) {
      final byTime = b.transferredAt.compareTo(a.transferredAt);
      if (byTime != 0) return byTime;
      return a.stt.compareTo(b.stt);
    });
    return copy;
  }

  static int get totalAmountVnd =>
      all.fold<int>(0, (sum, b) => sum + b.amountVnd);

  static int amountOnDate(DateTime day) {
    return all
        .where(
          (b) =>
              b.transferredAt.year == day.year &&
              b.transferredAt.month == day.month &&
              b.transferredAt.day == day.day,
        )
        .fold<int>(0, (sum, b) => sum + b.amountVnd);
  }

  static int amountInMonth(int year, int month) {
    return all
        .where(
          (b) =>
              b.transferredAt.year == year && b.transferredAt.month == month,
        )
        .fold<int>(0, (sum, b) => sum + b.amountVnd);
  }

  /// Điểm biểu đồ theo ngày / tháng / năm.
  /// [monthLabel] map (month, year) → nhãn trục (VI/EN từ l10n).
  static List<({String label, double value})> chartData(
    RevenueFilterPeriod period, {
    String Function(int month, int year)? monthLabel,
  }) {
    switch (period) {
      case RevenueFilterPeriod.day:
        final map = <String, int>{};
        final order = <String>[];
        final sorted = List<TransferBill>.from(all)
          ..sort((a, b) => a.transferredAt.compareTo(b.transferredAt));
        for (final b in sorted) {
          final key =
              '${b.transferredAt.day.toString().padLeft(2, '0')}/${b.transferredAt.month.toString().padLeft(2, '0')}';
          if (!map.containsKey(key)) order.add(key);
          map[key] = (map[key] ?? 0) + b.amountVnd;
        }
        return order
            .map((k) => (label: k, value: (map[k] ?? 0).toDouble()))
            .toList();

      case RevenueFilterPeriod.month:
        final map = <String, int>{};
        final order = <String>[];
        final sorted = List<TransferBill>.from(all)
          ..sort((a, b) => a.transferredAt.compareTo(b.transferredAt));
        for (final b in sorted) {
          final key = monthLabel?.call(
                b.transferredAt.month,
                b.transferredAt.year,
              ) ??
              '${b.transferredAt.month.toString().padLeft(2, '0')}/${b.transferredAt.year % 100}';
          if (!map.containsKey(key)) order.add(key);
          map[key] = (map[key] ?? 0) + b.amountVnd;
        }
        return order
            .map((k) => (label: k, value: (map[k] ?? 0).toDouble()))
            .toList();

      case RevenueFilterPeriod.year:
        final map = <String, int>{};
        final order = <String>[];
        final sorted = List<TransferBill>.from(all)
          ..sort((a, b) => a.transferredAt.compareTo(b.transferredAt));
        for (final b in sorted) {
          final key = '${b.transferredAt.year}';
          if (!map.containsKey(key)) order.add(key);
          map[key] = (map[key] ?? 0) + b.amountVnd;
        }
        return order
            .map((k) => (label: k, value: (map[k] ?? 0).toDouble()))
            .toList();
    }
  }
}
