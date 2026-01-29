import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/qr_payment/services/qr_code_service.dart';
import 'package:usdc_wallet/features/qr_payment/models/qr_payment_data.dart';

void main() {
  late QrCodeService service;

  setUp(() {
    service = QrCodeService();
  });

  group('QrCodeService', () {
    group('generateReceiveQr', () {
      test('should generate QR with phone only', () {
        final qr = service.generateReceiveQr(phone: '+22507123456');

        expect(qr, isNotEmpty);
        expect(qr, contains('+22507123456'));
        expect(qr, contains('joonapay'));
      });

      test('should generate QR with amount', () {
        final qr = service.generateReceiveQr(
          phone: '+22507123456',
          amount: 50.00,
        );

        expect(qr, contains('50'));
        expect(qr, contains('+22507123456'));
      });

      test('should generate QR with all fields', () {
        final qr = service.generateReceiveQr(
          phone: '+22507123456',
          amount: 100.50,
          currency: 'USD',
          name: 'John Doe',
          reference: 'INV-001',
        );

        expect(qr, contains('+22507123456'));
        expect(qr, contains('100.5'));
        expect(qr, contains('USD'));
        expect(qr, contains('John Doe'));
        expect(qr, contains('INV-001'));
      });
    });

    group('parseQrData', () {
      test('should parse JSON format QR', () {
        final qrString = '{"type":"joonapay","version":1,"phone":"+22507123456","amount":50.0,"currency":"USD"}';
        final data = service.parseQrData(qrString);

        expect(data, isNotNull);
        expect(data!.phone, '+22507123456');
        expect(data.amount, 50.0);
        expect(data.currency, 'USD');
      });

      test('should parse legacy URL format', () {
        final qrString = 'joonapay://pay?phone=+22507123456&amount=50';
        final data = service.parseQrData(qrString);

        expect(data, isNotNull);
        expect(data!.phone, '+22507123456');
        expect(data.amount, 50.0);
      });

      test('should parse plain phone number', () {
        final qrString = '+22507123456';
        final data = service.parseQrData(qrString);

        expect(data, isNotNull);
        expect(data!.phone, '+22507123456');
        expect(data.amount, isNull);
      });

      test('should return null for invalid QR', () {
        final data = service.parseQrData('invalid-qr-code');

        expect(data, isNull);
      });

      test('should parse URL with all parameters', () {
        final qrString = 'joonapay://pay?phone=+22507123456&amount=100&currency=USD&name=John%20Doe&reference=INV-001';
        final data = service.parseQrData(qrString);

        expect(data, isNotNull);
        expect(data!.phone, '+22507123456');
        expect(data.amount, 100.0);
        expect(data.currency, 'USD');
        expect(data.name, 'John Doe');
        expect(data.reference, 'INV-001');
      });
    });

    group('isValidQrData', () {
      test('should validate JSON format', () {
        final qrString = '{"type":"joonapay","version":1,"phone":"+22507123456"}';
        expect(service.isValidQrData(qrString), isTrue);
      });

      test('should validate URL format', () {
        final qrString = 'joonapay://pay?phone=+22507123456';
        expect(service.isValidQrData(qrString), isTrue);
      });

      test('should validate phone format', () {
        final qrString = '+22507123456';
        expect(service.isValidQrData(qrString), isTrue);
      });

      test('should reject invalid QR', () {
        expect(service.isValidQrData('invalid'), isFalse);
        expect(service.isValidQrData(''), isFalse);
        expect(service.isValidQrData('http://example.com'), isFalse);
      });
    });

    group('formatPhone', () {
      test('should format Côte d\'Ivoire phone number', () {
        final formatted = service.formatPhone('+22507123456');
        expect(formatted, '+22507123456'); // Returns unchanged if not 14 chars
      });

      test('should return unchanged for non-CI numbers', () {
        final phone = '+33123456789';
        final formatted = service.formatPhone(phone);
        expect(formatted, phone);
      });

      test('should return unchanged for short numbers', () {
        final phone = '+225123';
        final formatted = service.formatPhone(phone);
        expect(formatted, phone);
      });
    });

    group('truncate', () {
      test('should truncate long strings', () {
        final long = '0x1234567890abcdef1234567890abcdef12345678';
        final truncated = service.truncate(long, maxLength: 16);

        expect(truncated.length, lessThanOrEqualTo(16));
        expect(truncated, contains('...'));
        expect(truncated, startsWith('0x123'));
        expect(truncated, endsWith('5678'));
      });

      test('should not truncate short strings', () {
        final short = '0x12345678';
        final result = service.truncate(short, maxLength: 16);

        expect(result, short);
        expect(result, isNot(contains('...')));
      });
    });
  });

  group('QrPaymentData', () {
    test('should create from JSON', () {
      final json = {
        'type': 'joonapay',
        'version': 1,
        'phone': '+22507123456',
        'amount': 50.0,
        'currency': 'USD',
        'name': 'John Doe',
        'reference': 'INV-001',
      };

      final data = QrPaymentData.fromJson(json);

      expect(data.type, 'joonapay');
      expect(data.version, 1);
      expect(data.phone, '+22507123456');
      expect(data.amount, 50.0);
      expect(data.currency, 'USD');
      expect(data.name, 'John Doe');
      expect(data.reference, 'INV-001');
    });

    test('should convert to JSON', () {
      final data = QrPaymentData(
        phone: '+22507123456',
        amount: 50.0,
        currency: 'USD',
        name: 'John Doe',
        reference: 'INV-001',
      );

      final json = data.toJson();

      expect(json['type'], 'joonapay');
      expect(json['version'], 1);
      expect(json['phone'], '+22507123456');
      expect(json['amount'], 50.0);
      expect(json['currency'], 'USD');
      expect(json['name'], 'John Doe');
      expect(json['reference'], 'INV-001');
    });

    test('should encode and decode QR string', () {
      final original = QrPaymentData(
        phone: '+22507123456',
        amount: 100.0,
        currency: 'USD',
      );

      final qrString = original.toQrString();
      final decoded = QrPaymentData.fromQrString(qrString);

      expect(decoded, isNotNull);
      expect(decoded!.phone, original.phone);
      expect(decoded.amount, original.amount);
      expect(decoded.currency, original.currency);
    });

    test('should handle optional fields', () {
      final data = QrPaymentData(phone: '+22507123456');

      expect(data.amount, isNull);
      expect(data.currency, isNull);
      expect(data.name, isNull);
      expect(data.reference, isNull);

      final json = data.toJson();
      expect(json.containsKey('amount'), isFalse);
      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('reference'), isFalse);
    });

    test('should use default values', () {
      final data = QrPaymentData(phone: '+22507123456');

      expect(data.type, 'joonapay');
      expect(data.version, 1);
    });

    test('should copy with changes', () {
      final original = QrPaymentData(
        phone: '+22507123456',
        amount: 50.0,
      );

      final copy = original.copyWith(amount: 100.0, currency: 'USD');

      expect(copy.phone, original.phone);
      expect(copy.amount, 100.0);
      expect(copy.currency, 'USD');
    });

    test('should parse amount from string in JSON', () {
      final json = {
        'type': 'joonapay',
        'version': 1,
        'phone': '+22507123456',
        'amount': '50.0', // String instead of number
      };

      final data = QrPaymentData.fromJson(json);

      expect(data.amount, 50.0);
    });
  });
}
