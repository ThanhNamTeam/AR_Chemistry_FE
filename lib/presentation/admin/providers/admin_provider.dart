import 'package:flutter/foundation.dart';

import '../../../core/api/admin_activation_code_api.dart';
import '../../../core/api/admin_kit_api.dart';
import '../../../core/models/request/create_kit_request.dart';
import '../../../core/models/request/generate_activation_codes_request.dart';
import '../../../core/models/request/update_activation_code_status_request.dart';
import '../../../domain/models/activation_code_model.dart';
import '../../../domain/models/chemical_card_model.dart';
import '../../../domain/models/chemical_substance_model.dart';
import '../../../core/api/admin_substance_api.dart';
import '../../../domain/models/kit_model.dart';

enum StatsPeriod { day, week, month }

class TopSaleItem {
  final String cardId;
  final String symbol;
  final String name;
  final int purchases;

  const TopSaleItem({
    required this.cardId,
    required this.symbol,
    required this.name,
    required this.purchases,
  });
}

class RevenuePoint {
  final String label;
  final double amount;

  const RevenuePoint({
    required this.label,
    required this.amount,
  });
}

class AdminProvider extends ChangeNotifier {
  String _substanceFilter = 'ALL';
  String get substanceFilter => _substanceFilter;

  bool _isLoadingKitDetail = false;

  bool get isLoadingKitDetail => _isLoadingKitDetail;

  final AdminSubstanceApi _substanceApi = AdminSubstanceApi();

  AdminProvider();

  int _substancesPage = 0;
  int _substancesSize = 20;
  bool _hasMoreSubstances = true;
  bool _isLoadingMoreSubstances = false;

  final AdminActivationCodeApi _activationCodeApi = AdminActivationCodeApi();

  bool _isGeneratingActivationCodes = false;
  List<ActivationCodeModel> _lastGeneratedActivationCodes = [];

  bool get isGeneratingActivationCodes => _isGeneratingActivationCodes;
  List<ActivationCodeModel> get lastGeneratedActivationCodes =>
      _lastGeneratedActivationCodes;

  final AdminKitApi _kitApi = AdminKitApi();

  List<KitModel> _kits = [];
  bool _isLoadingKits = false;
  bool _isCreatingKit = false;

  List<KitModel> get kits => _kits;
  bool get isLoadingKits => _isLoadingKits;
  bool get isCreatingKit => _isCreatingKit;

  bool get hasMoreSubstances => _hasMoreSubstances;
  bool get isLoadingMoreSubstances => _isLoadingMoreSubstances;

  StatsPeriod _period = StatsPeriod.day;
  bool _initialized = false;

  List<ChemicalSubstanceModel> _substances = [];
  bool _isLoadingSubstances = false;
  String? _substancesError;

  List<ChemicalSubstanceModel> get substances => _substances;
  bool get isLoadingSubstances => _isLoadingSubstances;
  String? get substancesError => _substancesError;

  List<ActivationCodeModel> _activationCodes = [];
  bool _isLoadingActivationCodes = false;
  bool _isLoadingMoreActivationCodes = false;
  bool _hasMoreActivationCodes = true;
  bool _isUpdatingActivationCodeStatus = false;

  int _activationCodePage = 0;
  String _activationCodeStatusFilter = 'ALL';

  List<ActivationCodeModel> get activationCodes => _activationCodes;
  bool get isLoadingActivationCodes => _isLoadingActivationCodes;
  bool get isLoadingMoreActivationCodes => _isLoadingMoreActivationCodes;
  bool get hasMoreActivationCodes => _hasMoreActivationCodes;
  bool get isUpdatingActivationCodeStatus => _isUpdatingActivationCodeStatus;
  String get activationCodeStatusFilter => _activationCodeStatusFilter;

  StatsPeriod get period => _period;

  int get totalUsers => 1284;
  int get activeToday => 312;

  double get revenueDay => 2450000;
  double get revenueWeek => 18200000;
  double get revenueMonth => 74500000;

  double get currentRevenue {
    switch (_period) {
      case StatsPeriod.day:
        return revenueDay;
      case StatsPeriod.week:
        return revenueWeek;
      case StatsPeriod.month:
        return revenueMonth;
    }
  }

  bool? get _activeParam {
    if (_substanceFilter == 'FULL_KIT') return true;
    if (_substanceFilter == 'INACTIVE') return false;
    return null;
  }

  bool? get _includedInFullKitParam {
    if (_substanceFilter == 'FULL_KIT') return true;
    if (_substanceFilter == 'NOT_FULL_KIT') return false;
    return null;
  }

  String? get _typeParam {
    if (_substanceFilter == 'ELEMENT') return 'ELEMENT';
    if (_substanceFilter == 'COMPOUND') return 'COMPOUND';
    return null;
  }

  List<RevenuePoint> get revenueChartData {
    switch (_period) {
      case StatsPeriod.day:
        return const [
          RevenuePoint(label: '6h', amount: 120000),
          RevenuePoint(label: '9h', amount: 340000),
          RevenuePoint(label: '12h', amount: 520000),
          RevenuePoint(label: '15h', amount: 410000),
          RevenuePoint(label: '18h', amount: 680000),
          RevenuePoint(label: '21h', amount: 380000),
        ];
      case StatsPeriod.week:
        return const [
          RevenuePoint(label: 'T2', amount: 2100000),
          RevenuePoint(label: 'T3', amount: 2450000),
          RevenuePoint(label: 'T4', amount: 1980000),
          RevenuePoint(label: 'T5', amount: 3120000),
          RevenuePoint(label: 'T6', amount: 2890000),
          RevenuePoint(label: 'T7', amount: 3560000),
          RevenuePoint(label: 'CN', amount: 2210000),
        ];
      case StatsPeriod.month:
        return const [
          RevenuePoint(label: 'T1', amount: 18200000),
          RevenuePoint(label: 'T2', amount: 21500000),
          RevenuePoint(label: 'T3', amount: 19800000),
          RevenuePoint(label: 'T4', amount: 15000000),
        ];
    }
  }

  List<TopSaleItem> get topSales {
    final cards = ChemicalData.cards.where((c) => c.id != 'H' && c.id != 'O');
    final list = cards
        .map(
          (c) => TopSaleItem(
        cardId: c.id,
        symbol: c.symbol,
        name: c.name,
        purchases: _mockPurchases(c.id, _period),
      ),
    )
        .toList()
      ..sort((a, b) => b.purchases.compareTo(a.purchases));

    return list.take(5).toList();
  }

  int _mockPurchases(String id, StatsPeriod p) {
    final base = id.hashCode.abs() % 50;

    switch (p) {
      case StatsPeriod.day:
        return 5 + base % 12;
      case StatsPeriod.week:
        return 20 + base % 40;
      case StatsPeriod.month:
        return 80 + base % 120;
    }
  }

  /// Mock cũ vẫn giữ tạm cho các tab khác chưa migrate.
  List<ChemicalCardModel> get catalogCards => ChemicalData.cards;
  List<BundleModel> get bundles => ChemicalData.bundles;

  final List<Map<String, String>> _reactions = [
    {
      'id': 'r1',
      'name': 'H₂ + O₂ → H₂O',
      'topic': 'Tổng hợp nước',
    },
    {
      'id': 'r2',
      'name': 'Na + Cl₂ → NaCl',
      'topic': 'Muối ăn',
    },
    {
      'id': 'r3',
      'name': 'CH₄ + O₂ → CO₂ + H₂O',
      'topic': 'Đốt cháy',
    },
  ];

  List<Map<String, String>> get reactions => List.unmodifiable(_reactions);

  void setPeriod(StatsPeriod p) {
    _period = p;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await loadSubstances();
  }

  Future<KitModel> getKitByCode(String code) async {
    _isLoadingKitDetail = true;
    notifyListeners();

    try {
      return await _kitApi.getKitByCode(code);
    } finally {
      _isLoadingKitDetail = false;
      notifyListeners();
    }
  }

  Future<void> loadActivationCodes({bool force = false}) async {
    if (_isLoadingActivationCodes) return;
    if (!force && _activationCodes.isNotEmpty) return;

    _activationCodePage = 0;
    _hasMoreActivationCodes = true;

    _isLoadingActivationCodes = true;
    notifyListeners();

    try {
      final status = _activationCodeStatusFilter == 'ALL'
          ? null
          : _activationCodeStatusFilter;

      final result = await _activationCodeApi.getActivationCodes(
        page: _activationCodePage,
        size: 20,
        status: status,
      );

      _activationCodes = result;
      _hasMoreActivationCodes = result.length >= 20;
    } finally {
      _isLoadingActivationCodes = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreActivationCodes() async {
    if (_isLoadingActivationCodes ||
        _isLoadingMoreActivationCodes ||
        !_hasMoreActivationCodes) {
      return;
    }

    _isLoadingMoreActivationCodes = true;
    notifyListeners();

    try {
      final nextPage = _activationCodePage + 1;

      final status = _activationCodeStatusFilter == 'ALL'
          ? null
          : _activationCodeStatusFilter;

      final result = await _activationCodeApi.getActivationCodes(
        page: nextPage,
        size: 20,
        status: status,
      );

      _activationCodes.addAll(result);
      _activationCodePage = nextPage;
      _hasMoreActivationCodes = result.length >= 20;
    } finally {
      _isLoadingMoreActivationCodes = false;
      notifyListeners();
    }
  }

  Future<void> changeActivationCodeStatusFilter(String status) async {
    if (_activationCodeStatusFilter == status) return;

    _activationCodeStatusFilter = status;
    _activationCodes = [];
    notifyListeners();

    await loadActivationCodes(force: true);
  }

  Future<void> searchActivationCodeByCode(String code) async {
    final keyword = code.trim();
    if (keyword.isEmpty) {
      await loadActivationCodes(force: true);
      return;
    }

    _isLoadingActivationCodes = true;
    notifyListeners();

    try {
      final result = await _activationCodeApi.getByCode(keyword);
      _activationCodes = [result];
      _hasMoreActivationCodes = false;
    } finally {
      _isLoadingActivationCodes = false;
      notifyListeners();
    }
  }

  Future<void> updateActivationCodeStatus(
      String id,
      String status,
      ) async {
    if (_isUpdatingActivationCodeStatus) return;

    _isUpdatingActivationCodeStatus = true;
    notifyListeners();

    try {
      final updated = await _activationCodeApi.updateStatus(
        id,
        UpdateActivationCodeStatusRequest(status: status),
      );

      final index = _activationCodes.indexWhere((e) => e.id == id);
      if (index != -1) {
        _activationCodes[index] = updated;
      }
    } finally {
      _isUpdatingActivationCodeStatus = false;
      notifyListeners();
    }
  }

  Future<List<ActivationCodeModel>> generateActivationCodes(
      GenerateActivationCodesRequest request,
      ) async {
    if (_isGeneratingActivationCodes) return _lastGeneratedActivationCodes;

    _isGeneratingActivationCodes = true;
    notifyListeners();

    try {
      final codes = await _activationCodeApi.generateCodes(request);
      _lastGeneratedActivationCodes = codes;
      return codes;
    } finally {
      _isGeneratingActivationCodes = false;
      notifyListeners();
    }
  }

  Future<void> changeSubstanceFilter(String filter) async {
    if (_substanceFilter == filter && _substances.isNotEmpty) return;

    _substanceFilter = filter;
    await loadSubstances(force: true);
  }

  Future<void> loadKits({bool force = false}) async {
    if (_isLoadingKits) return;
    if (!force && _kits.isNotEmpty) return;

    _isLoadingKits = true;
    notifyListeners();

    try {
      _kits = await _kitApi.getKits();
    } finally {
      _isLoadingKits = false;
      notifyListeners();
    }
  }

  Future<void> createKit(CreateKitRequest request) async {
    if (_isCreatingKit) return;

    _isCreatingKit = true;
    notifyListeners();

    try {
      final createdKit = await _kitApi.createKit(request);
      _kits.insert(0, createdKit);
    } finally {
      _isCreatingKit = false;
      notifyListeners();
    }
  }

  Future<void> loadSubstances({
    bool force = false,
  }) async {
    if (_isLoadingSubstances) return;

    if (!force && _substances.isNotEmpty) {
      return;
    }

    _isLoadingSubstances = true;
    _substancesError = null;
    _substancesPage = 0;
    _hasMoreSubstances = true;
    notifyListeners();

    try {
      final page = await _substanceApi.getSubstances(
        page: _substancesPage,
        size: _substancesSize,
        active: _activeParam,
        type: _typeParam,
        includedInFullKit: _includedInFullKitParam,
      );

      _substances = page.items;
      _hasMoreSubstances = page.hasNext;
      _substancesPage = page.page + 1;
    } catch (e) {
      _substancesError = e.toString();
      debugPrint('LOAD_SUBSTANCES_ERROR: $e');
    } finally {
      _isLoadingSubstances = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreSubstances() async {
    if (_isLoadingSubstances) return;
    if (_isLoadingMoreSubstances) return;
    if (!_hasMoreSubstances) return;

    _isLoadingMoreSubstances = true;
    _substancesError = null;
    notifyListeners();

    try {
      final page = await _substanceApi.getSubstances(
        page: _substancesPage,
        size: _substancesSize,
        active: _activeParam,
        type: _typeParam,
        includedInFullKit: _includedInFullKitParam,
      );

      _substances = [
        ..._substances,
        ...page.items,
      ];

      _hasMoreSubstances = page.hasNext;
      _substancesPage = page.page + 1;
    } catch (e) {
      _substancesError = e.toString();
      debugPrint('LOAD_MORE_SUBSTANCES_ERROR: $e');
    } finally {
      _isLoadingMoreSubstances = false;
      notifyListeners();
    }
  }

  Future<void> updateSubstanceActive(
      String id,
      bool active,
      ) async {
    try {
      final updated = await _substanceApi.updateSubstanceActive(
        id: id,
        active: active,
      );

      _substances = _substances
          .map((item) => item.id == id ? updated : item)
          .toList();

      notifyListeners();
    } catch (e) {
      _substancesError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSubstanceIncludedInFullKit(
      String id,
      bool includedInFullKit,
      ) async {
    try {
      final updated = await _substanceApi.updateSubstanceIncludedInFullKit(
        id: id,
        includedInFullKit: includedInFullKit,
      );

      _substances = _substances
          .map((item) => item.id == id ? updated : item)
          .toList();

      notifyListeners();
    } catch (e) {
      _substancesError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void addReaction(String name, String topic) {
    _reactions.add({
      'id': 'r_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'topic': topic,
    });
    notifyListeners();
  }

  void addBundleSale({
    required String name,
    required List<String> cardIds,
    required int originalPrice,
    required int discountPercent,
  }) {
    notifyListeners();
  }
}