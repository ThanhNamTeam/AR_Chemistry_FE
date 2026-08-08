import 'package:flutter_test/flutter_test.dart';
import 'package:labedu/domain/models/chemical_substance_model.dart';

// ─── Helper ─────────────────────────────────────────────────────────────────

Map<String, dynamic> _baseJson({Map<String, dynamic> overrides = const {}}) {
  return <String, dynamic>{
    'id': '1',
    'formula': 'Fe',
    'name': 'Iron',
    'vietnameseName': 'Sắt',
    'type': 'ELEMENT',
    'chemicalGroup': 'TRANSITION_METAL',
    'state': 'SOLID',
    'molarMass': 55.845,
    'active': true,
    'includedInFullKit': false,
    ...overrides,
  };
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // ── fromJson ──────────────────────────────────────────────────────────────

  group('ChemicalSubstanceModel.fromJson – thành công', () {
    test('parse đầy đủ', () {
      final m = ChemicalSubstanceModel.fromJson(_baseJson());
      expect(m.id, '1');
      expect(m.formula, 'Fe');
      expect(m.name, 'Iron');
      expect(m.vietnameseName, 'Sắt');
      expect(m.type, 'ELEMENT');
      expect(m.chemicalGroup, 'TRANSITION_METAL');
      expect(m.state, 'SOLID');
      expect(m.molarMass, closeTo(55.845, 0.001));
      expect(m.active, isTrue);
      expect(m.includedInFullKit, isFalse);
    });

    test('molarMass dạng String hợp lệ', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'molarMass': '18.015'}));
      expect(m.molarMass, closeTo(18.015, 0.001));
    });

    test('molarMass dạng int', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'molarMass': 56}));
      expect(m.molarMass, closeTo(56.0, 0.001));
    });

    test('active = false', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'active': false}));
      expect(m.active, isFalse);
    });

    test('includedInFullKit = true', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'includedInFullKit': true}));
      expect(m.includedInFullKit, isTrue);
    });
  });

  group('ChemicalSubstanceModel.fromJson – null / thiếu field', () {
    test('id null → empty string', () {
      final m = ChemicalSubstanceModel.fromJson(_baseJson(overrides: {'id': null}));
      expect(m.id, '');
    });

    test('molarMass null → null', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'molarMass': null}));
      expect(m.molarMass, isNull);
    });

    test('molarMass chuỗi rác → null', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'molarMass': 'abc'}));
      expect(m.molarMass, isNull);
    });

    test('vietnameseName null → vẫn tạo được', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'vietnameseName': null}));
      expect(m.vietnameseName, isNull);
    });

    test('elementDetail null → null', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'elementDetail': null}));
      expect(m.elementDetail, isNull);
    });
  });

  // ── displayName ───────────────────────────────────────────────────────────

  group('displayName', () {
    test('vietnameseName hợp lệ → ưu tiên VI', () {
      final m = ChemicalSubstanceModel.fromJson(_baseJson());
      expect(m.displayName, 'Sắt');
    });

    test('vietnameseName null → fallback name', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'vietnameseName': null}));
      expect(m.displayName, 'Iron');
    });

    test('vietnameseName chỉ khoảng trắng → fallback name', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'vietnameseName': '   '}));
      expect(m.displayName, 'Iron');
    });

    test('vietnameseName rỗng → fallback name', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'vietnameseName': ''}));
      expect(m.displayName, 'Iron');
    });
  });

  // ── isElement / isCompound ────────────────────────────────────────────────

  group('isElement / isCompound', () {
    test('ELEMENT → isElement=true, isCompound=false', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'type': 'ELEMENT'}));
      expect(m.isElement, isTrue);
      expect(m.isCompound, isFalse);
    });

    test('COMPOUND → isElement=false, isCompound=true', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'type': 'COMPOUND'}));
      expect(m.isElement, isFalse);
      expect(m.isCompound, isTrue);
    });

    test('SIMPLE_MOLECULE → isCompound=true', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'type': 'SIMPLE_MOLECULE'}));
      expect(m.isCompound, isTrue);
    });

    test('type không hợp lệ → cả hai false', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'type': 'UNKNOWN'}));
      expect(m.isElement, isFalse);
      expect(m.isCompound, isFalse);
    });

    test('type rỗng → cả hai false', () {
      final m = ChemicalSubstanceModel.fromJson(
          _baseJson(overrides: {'type': ''}));
      expect(m.isElement, isFalse);
      expect(m.isCompound, isFalse);
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────

  group('copyWith', () {
    final original = ChemicalSubstanceModel.fromJson(_baseJson());

    test('copyWith formula → formula đổi, phần còn lại giữ nguyên', () {
      final copy = original.copyWith(formula: 'Zn');
      expect(copy.formula, 'Zn');
      expect(copy.name, original.name);
      expect(copy.active, original.active);
      expect(copy.type, original.type);
    });

    test('copyWith không tham số → giống original', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.formula, original.formula);
      expect(copy.molarMass, original.molarMass);
    });

    test('copyWith active → đổi được', () {
      final copy = original.copyWith(active: false);
      expect(copy.active, isFalse);
    });
  });

  // ── ElementDetailModel ────────────────────────────────────────────────────

  group('ElementDetailModel.fromJson', () {
    test('parse đầy đủ', () {
      final el = ElementDetailModel.fromJson({
        'atomicNumber': 26,
        'symbol': 'Fe',
        'periodicCategory': 'TRANSITION_METAL',
        'atomicMass': 55.845,
        'period': 4,
        'groupNumber': 8,
      });
      expect(el.atomicNumber, 26);
      expect(el.symbol, 'Fe');
      expect(el.periodicCategory, 'TRANSITION_METAL');
      expect(el.atomicMass, closeTo(55.845, 0.001));
      expect(el.period, 4);
      expect(el.groupNumber, 8);
    });

    test('atomicNumber dạng String → parse thành int', () {
      final el = ElementDetailModel.fromJson({'atomicNumber': '26'});
      expect(el.atomicNumber, 26);
    });

    test('json rỗng → tất cả null, không crash', () {
      final el = ElementDetailModel.fromJson({});
      expect(el.atomicNumber, isNull);
      expect(el.symbol, isNull);
      expect(el.periodicCategory, isNull);
      expect(el.atomicMass, isNull);
    });

    test('atomicNumber chuỗi rác → null', () {
      final el = ElementDetailModel.fromJson({'atomicNumber': 'abc'});
      expect(el.atomicNumber, isNull);
    });
  });

  // ── CompoundDetailModel ───────────────────────────────────────────────────

  group('CompoundDetailModel.fromJson', () {
    test('parse đầy đủ', () {
      final c = CompoundDetailModel.fromJson({
        'iupacName': 'Sulfuric acid',
        'casNumber': '7664-93-9',
        'compoundClass': 'ACID',
        'usageNote': 'Dùng trong phòng thí nghiệm',
        'reactionProductOnly': false,
        'physicalInKit': true,
      });
      expect(c.iupacName, 'Sulfuric acid');
      expect(c.casNumber, '7664-93-9');
      expect(c.reactionProductOnly, isFalse);
      expect(c.physicalInKit, isTrue);
    });

    test('json rỗng → tất cả null, không crash', () {
      final c = CompoundDetailModel.fromJson({});
      expect(c.iupacName, isNull);
      expect(c.reactionProductOnly, isNull);
    });
  });
}
