import 'package:flutter_test/flutter_test.dart';

import 'package:labedu/core/models/response/ar_access_response.dart';
import 'package:labedu/core/models/response/card_bundle_response.dart';
import 'package:labedu/core/models/response/chemical_card_response.dart';
import 'package:labedu/core/models/response/my_single_card_purchase_response.dart';
import 'package:labedu/core/models/response/package_ownership_response.dart';
import 'package:labedu/core/models/response/package_response.dart';
import 'package:labedu/core/models/response/page_response.dart';
import 'package:labedu/core/models/response/payment_response.dart';
import 'package:labedu/core/models/response/presigned_upload_response.dart';
import 'package:labedu/core/models/response/single_card_purchase_response.dart';
import 'package:labedu/core/models/response/single_card_shop_response.dart';

void main() {
  // ─── ChemicalCardResponse ────────────────────────────────────────────────
  group('ChemicalCardResponse.fromJson', () {
    test('parses full JSON correctly', () {
      final card = ChemicalCardResponse.fromJson({
        'id': 'H',
        'atomicNumber': 1,
        'symbol': 'H',
        'name': 'Hydrogen',
        'category': 'Diatomic nonmetal',
        'atomicMass': 1.008,
        'period': 1,
        'groupNumber': 1,
        'price': 3000,
        'active': true,
        'purchasable': true,
      });
      expect(card.id, 'H');
      expect(card.atomicNumber, 1);
      expect(card.symbol, 'H');
      expect(card.name, 'Hydrogen');
      expect(card.category, 'Diatomic nonmetal');
      expect(card.atomicMass, 1.008);
      expect(card.period, 1);
      expect(card.groupNumber, 1);
      expect(card.price, 3000);
      expect(card.active, true);
      expect(card.purchasable, true);
    });

    test('parses JSON with nullable fields missing', () {
      final card = ChemicalCardResponse.fromJson({
        'id': 'X',
        'atomicNumber': 99,
        'symbol': 'X',
        'name': 'Unknown',
        'price': 0,
        'active': false,
        'purchasable': false,
      });
      expect(card.category, isNull);
      expect(card.atomicMass, isNull);
      expect(card.period, isNull);
      expect(card.groupNumber, isNull);
      expect(card.active, false);
    });

    test('_parseInt handles double price', () {
      final card = ChemicalCardResponse.fromJson({
        'id': 'X',
        'atomicNumber': 1,
        'symbol': 'X',
        'name': 'X',
        'price': 3000.7,
        'active': true,
        'purchasable': true,
      });
      expect(card.price, 3000);
    });

    test('_parseInt handles null price', () {
      final card = ChemicalCardResponse.fromJson({
        'id': 'X',
        'atomicNumber': 1,
        'symbol': 'X',
        'name': 'X',
        'price': null,
        'active': true,
        'purchasable': true,
      });
      expect(card.price, 0);
    });
  });

  // ─── CardBundleResponse ──────────────────────────────────────────────────
  group('CardBundleResponse.fromJson', () {
    final sampleCardJson = {
      'id': 'H',
      'atomicNumber': 1,
      'symbol': 'H',
      'name': 'Hydrogen',
      'price': 3000,
      'active': true,
      'purchasable': true,
    };

    test('parses full JSON with cards', () {
      final bundle = CardBundleResponse.fromJson({
        'id': 'bundle1',
        'name': 'Starter Pack',
        'description': 'Basic elements',
        'originalPrice': 10000,
        'discountedPrice': 8000,
        'active': true,
        'purchasable': true,
        'cards': [sampleCardJson],
      });
      expect(bundle.id, 'bundle1');
      expect(bundle.name, 'Starter Pack');
      expect(bundle.originalPrice, 10000);
      expect(bundle.discountedPrice, 8000);
      expect(bundle.active, true);
      expect(bundle.cards.length, 1);
    });

    test('hasSale is true when originalPrice > discountedPrice', () {
      final bundle = CardBundleResponse.fromJson({
        'id': 'b',
        'name': 'n',
        'description': 'd',
        'originalPrice': 10000,
        'discountedPrice': 8000,
        'active': true,
        'purchasable': true,
        'cards': [],
      });
      expect(bundle.hasSale, true);
      expect(bundle.salePercent, 20);
    });

    test('hasSale is false when prices equal', () {
      final bundle = CardBundleResponse.fromJson({
        'id': 'b',
        'name': 'n',
        'description': 'd',
        'originalPrice': 5000,
        'discountedPrice': 5000,
        'active': true,
        'purchasable': true,
        'cards': [],
      });
      expect(bundle.hasSale, false);
      expect(bundle.salePercent, 0);
    });

    test('salePercent is 0 when originalPrice is zero', () {
      final bundle = CardBundleResponse.fromJson({
        'id': 'b',
        'name': 'n',
        'description': 'd',
        'originalPrice': 0,
        'discountedPrice': 0,
        'active': false,
        'purchasable': false,
        'cards': [],
      });
      expect(bundle.salePercent, 0);
    });

    test('_toIntPrice handles double', () {
      final bundle = CardBundleResponse.fromJson({
        'id': 'b',
        'name': 'n',
        'description': 'd',
        'originalPrice': 9999.9,
        'discountedPrice': 7999.5,
        'active': true,
        'purchasable': true,
        'cards': [],
      });
      expect(bundle.originalPrice, 10000);
      expect(bundle.discountedPrice, 8000);
    });

    test('handles null prices and cards', () {
      final bundle = CardBundleResponse.fromJson({
        'id': 'b',
        'name': 'n',
        'description': 'd',
        'originalPrice': null,
        'discountedPrice': null,
        'active': false,
        'purchasable': false,
        'cards': null,
      });
      expect(bundle.originalPrice, 0);
      expect(bundle.discountedPrice, 0);
      expect(bundle.cards, isEmpty);
    });
  });

  // ─── PackageResponse ─────────────────────────────────────────────────────
  group('PackageResponse.fromJson', () {
    test('parses full JSON', () {
      final pkg = PackageResponse.fromJson({
        'id': 'pkg1',
        'packageType': 'AR_30_DAYS',
        'name': 'AR 30 ngày',
        'price': 50000,
        'durationDays': 30,
      });
      expect(pkg.id, 'pkg1');
      expect(pkg.packageType, 'AR_30_DAYS');
      expect(pkg.name, 'AR 30 ngày');
      expect(pkg.price, 50000);
      expect(pkg.durationDays, 30);
    });

    test('_parsePrice handles double', () {
      final pkg = PackageResponse.fromJson({
        'id': 'p',
        'packageType': 'T',
        'name': 'N',
        'price': 49999.9,
        'durationDays': 30,
      });
      expect(pkg.price, 50000);
    });

    test('_parsePrice handles string', () {
      final pkg = PackageResponse.fromJson({
        'id': 'p',
        'packageType': 'T',
        'name': 'N',
        'price': '50000',
        'durationDays': 30,
      });
      expect(pkg.price, 50000);
    });

    test('_parsePrice handles null', () {
      final pkg = PackageResponse.fromJson({
        'id': 'p',
        'packageType': 'T',
        'name': 'N',
        'price': null,
        'durationDays': 0,
      });
      expect(pkg.price, 0);
    });
  });

  // ─── PackageOwnershipResponse ────────────────────────────────────────────
  group('PackageOwnershipResponse.fromJson', () {
    test('parses owned package', () {
      final resp = PackageOwnershipResponse.fromJson({
        'owned': true,
        'accessType': 'AR_30_DAYS',
        'startAt': '2024-01-01T00:00:00Z',
        'expiredAt': '2024-01-31T23:59:59Z',
        'remainingDays': 15,
        'message': 'Active',
      });
      expect(resp.owned, true);
      expect(resp.accessType, 'AR_30_DAYS');
      expect(resp.remainingDays, 15);
      expect(resp.message, 'Active');
    });

    test('parses unowned package with defaults', () {
      final resp = PackageOwnershipResponse.fromJson({
        'owned': false,
        'accessType': 'FREE',
        'startAt': null,
        'expiredAt': null,
        'remainingDays': 0,
        'message': '',
      });
      expect(resp.owned, false);
      expect(resp.remainingDays, 0);
    });

    test('remainingDays parses string', () {
      final resp = PackageOwnershipResponse.fromJson({
        'owned': true,
        'accessType': 'AR',
        'startAt': null,
        'expiredAt': null,
        'remainingDays': '7',
        'message': 'ok',
      });
      expect(resp.remainingDays, 7);
    });
  });

  // ─── ArAccessResponse ────────────────────────────────────────────────────
  group('ArAccessResponse.fromJson', () {
    test('parses JSON with dates', () {
      final resp = ArAccessResponse.fromJson({
        'canScanAR': true,
        'accessType': 'AR_30_DAYS',
        'startAt': '2024-01-01T00:00:00Z',
        'expiredAt': '2024-01-31T00:00:00Z',
        'remainingDays': 10,
        'message': 'OK',
      });
      expect(resp.canScanAR, true);
      expect(resp.accessType, 'AR_30_DAYS');
      expect(resp.startAt, isNotNull);
      expect(resp.expiredAt, isNotNull);
      expect(resp.remainingDays, 10);
    });

    test('parses JSON without dates', () {
      final resp = ArAccessResponse.fromJson({
        'canScanAR': false,
        'accessType': 'FREE',
        'startAt': null,
        'expiredAt': null,
        'remainingDays': 0,
        'message': 'No access',
      });
      expect(resp.canScanAR, false);
      expect(resp.startAt, isNull);
      expect(resp.expiredAt, isNull);
    });

    test('defaults accessType to FREE when null', () {
      final resp = ArAccessResponse.fromJson({
        'canScanAR': false,
        'remainingDays': 0,
        'message': '',
      });
      expect(resp.accessType, 'FREE');
    });
  });

  // ─── PaymentResponse ─────────────────────────────────────────────────────
  group('PaymentResponse.fromJson', () {
    test('parses full JSON', () {
      final resp = PaymentResponse.fromJson({
        'id': 'pay1',
        'email': 'user@test.com',
        'packageEntity': {'name': 'AR 30 ngày'},
        'amount': 50000.0,
        'proofImageUrl': 'https://example.com/proof.jpg',
        'status': 'PENDING',
      });
      expect(resp.id, 'pay1');
      expect(resp.email, 'user@test.com');
      expect(resp.packageName, 'AR 30 ngày');
      expect(resp.amount, 50000.0);
      expect(resp.proofImageUrl, 'https://example.com/proof.jpg');
      expect(resp.status, 'PENDING');
    });
  });

  // ─── PresignedUploadResponse ─────────────────────────────────────────────
  group('PresignedUploadResponse.fromJson', () {
    test('parses correctly', () {
      final resp = PresignedUploadResponse.fromJson({
        'uploadFileId': 42,
        'uploadUrl': 'https://s3.example.com/upload',
        'fileUrl': 'https://cdn.example.com/file.jpg',
        'storageKey': 'uploads/file.jpg',
        'contentType': 'image/jpeg',
      });
      expect(resp.uploadFileId, 42);
      expect(resp.uploadUrl, 'https://s3.example.com/upload');
      expect(resp.fileUrl, 'https://cdn.example.com/file.jpg');
      expect(resp.storageKey, 'uploads/file.jpg');
      expect(resp.contentType, 'image/jpeg');
    });
  });

  // ─── PageResponse ────────────────────────────────────────────────────────
  group('PageResponse.fromJson', () {
    test('parses paginated list', () {
      final resp = PageResponse.fromJson(
        {
          'items': [
            {'id': '1', 'name': 'item1'},
            {'id': '2', 'name': 'item2'},
          ],
          'page': 0,
          'size': 10,
          'totalItems': 2,
          'totalPages': 1,
          'first': true,
          'last': true,
          'hasNext': false,
          'hasPrevious': false,
        },
        (json) => json['name'] as String,
      );
      expect(resp.items, ['item1', 'item2']);
      expect(resp.page, 0);
      expect(resp.size, 10);
      expect(resp.totalItems, 2);
      expect(resp.totalPages, 1);
      expect(resp.first, true);
      expect(resp.last, true);
      expect(resp.hasNext, false);
      expect(resp.hasPrevious, false);
    });

    test('handles null items', () {
      final resp = PageResponse.fromJson(
        {
          'items': null,
          'page': 0,
          'size': 10,
          'totalItems': 0,
          'totalPages': 0,
          'first': true,
          'last': true,
          'hasNext': false,
          'hasPrevious': false,
        },
        (json) => json['name'] as String,
      );
      expect(resp.items, isEmpty);
    });

    test('_parseInt handles string page', () {
      final resp = PageResponse.fromJson(
        {
          'items': [],
          'page': '2',
          'size': '5',
          'totalItems': '10',
          'totalPages': '2',
          'first': false,
          'last': false,
          'hasNext': true,
          'hasPrevious': true,
        },
        (json) => '',
      );
      expect(resp.page, 2);
      expect(resp.size, 5);
      expect(resp.totalItems, 10);
      expect(resp.totalPages, 2);
    });
  });

  // ─── MySingleCardPurchaseResponse ────────────────────────────────────────
  group('MySingleCardPurchaseResponse.fromJson', () {
    test('parses full JSON with dates', () {
      final resp = MySingleCardPurchaseResponse.fromJson({
        'purchaseId': 'pur1',
        'singleCardId': 'card1',
        'singleCardCode': 'CODE-001',
        'singleCardName': 'Hydrogen Card',
        'substanceId': 'sub1',
        'substanceFormula': 'H',
        'substanceName': 'Hydrogen',
        'substanceVietnameseName': 'Hidro',
        'qrContent': 'qr-data',
        'qrImageUrl': 'https://qr.example.com/1.png',
        'purchasedAt': '2024-01-01T10:00:00Z',
        'startAt': '2024-01-01T00:00:00Z',
        'expiredAt': '2024-03-31T23:59:59Z',
        'purchaseStatus': 'ACTIVE',
        'accessStatus': 'ACCESSIBLE',
        'active': true,
      });
      expect(resp.purchaseId, 'pur1');
      expect(resp.singleCardId, 'card1');
      expect(resp.singleCardCode, 'CODE-001');
      expect(resp.substanceFormula, 'H');
      expect(resp.purchasedAt, isNotNull);
      expect(resp.startAt, isNotNull);
      expect(resp.expiredAt, isNotNull);
      expect(resp.active, true);
    });

    test('parses JSON with null dates and optional fields', () {
      final resp = MySingleCardPurchaseResponse.fromJson({
        'purchaseId': 'pur2',
        'singleCardId': 'card2',
        'active': false,
      });
      expect(resp.purchasedAt, isNull);
      expect(resp.startAt, isNull);
      expect(resp.expiredAt, isNull);
      expect(resp.singleCardCode, isNull);
      expect(resp.active, false);
    });
  });

  // ─── SingleCardPurchaseResponse ──────────────────────────────────────────
  group('SingleCardPurchaseResponse.fromJson', () {
    test('parses full JSON', () {
      final resp = SingleCardPurchaseResponse.fromJson({
        'purchaseId': 'pur1',
        'singleCardId': 'card1',
        'singleCardName': 'Hydrogen Card',
        'substanceId': 'sub1',
        'substanceName': 'Hydrogen',
        'substanceFormula': 'H',
        'qrContent': 'qr-data',
        'qrImageUrl': 'https://qr.example.com/1.png',
        'purchasedAt': '2024-01-01T10:00:00Z',
        'expiredAt': '2024-03-31T23:59:59Z',
        'status': 'ACTIVE',
      });
      expect(resp.purchaseId, 'pur1');
      expect(resp.substanceFormula, 'H');
      expect(resp.purchasedAt, isNotNull);
      expect(resp.expiredAt, isNotNull);
      expect(resp.status, 'ACTIVE');
    });

    test('handles null dates', () {
      final resp = SingleCardPurchaseResponse.fromJson({
        'purchaseId': '',
        'singleCardId': '',
        'singleCardName': '',
        'substanceId': '',
        'substanceName': '',
        'qrContent': '',
        'status': '',
      });
      expect(resp.purchasedAt, isNull);
      expect(resp.expiredAt, isNull);
    });
  });

  // ─── SingleCardShopResponse ──────────────────────────────────────────────
  group('SingleCardShopResponse.fromJson', () {
    test('parses full JSON', () {
      final resp = SingleCardShopResponse.fromJson({
        'id': 'sc1',
        'code': 'CARD-H',
        'name': 'Hydrogen Card',
        'description': 'Element card',
        'kpPrice': 3000,
        'durationDays': 30,
        'active': true,
        'substanceId': 'sub-h',
        'substanceFormula': 'H',
        'substanceName': 'Hydrogen',
        'substanceVietnameseName': 'Hidro',
        'frontImageUrl': 'https://example.com/front.jpg',
        'backImageUrl': 'https://example.com/back.jpg',
      });
      expect(resp.id, 'sc1');
      expect(resp.code, 'CARD-H');
      expect(resp.kpPrice, 3000);
      expect(resp.durationDays, 30);
      expect(resp.substanceVietnameseName, 'Hidro');
      expect(resp.frontImageUrl, 'https://example.com/front.jpg');
    });

    test('_toInt handles double kpPrice', () {
      final resp = SingleCardShopResponse.fromJson({
        'id': 'sc1',
        'code': 'C',
        'name': 'N',
        'kpPrice': 2999.9,
        'durationDays': 30.5,
        'active': true,
        'substanceId': 's',
        'substanceFormula': 'F',
        'substanceName': 'N',
      });
      expect(resp.kpPrice, 3000);
      expect(resp.durationDays, 31);
    });

    test('handles null optional fields', () {
      final resp = SingleCardShopResponse.fromJson({
        'id': 'sc1',
        'code': 'C',
        'name': 'N',
        'kpPrice': 0,
        'durationDays': 0,
        'active': false,
        'substanceId': 's',
        'substanceFormula': 'F',
        'substanceName': 'N',
      });
      expect(resp.description, isNull);
      expect(resp.substanceVietnameseName, isNull);
      expect(resp.frontImageUrl, isNull);
      expect(resp.backImageUrl, isNull);
    });
  });
}
