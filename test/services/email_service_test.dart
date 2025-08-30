import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/email_service.dart';
import 'package:flutter_application_1/models/map_pin.dart';

void main() {
  group('EmailService Tests', () {
    late EmailService emailService;
    late List<MapPin> testPins;

    setUp(() {
      emailService = EmailService();
      testPins = [
        MapPin(
          id: 'pin1',
          latitude: 35.6762,
          longitude: 139.6503,
          createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        ),
        MapPin(
          id: 'pin2',
          latitude: 36.0,
          longitude: 140.0,
          createdAt: DateTime(2024, 1, 1, 13, 0, 1), // 13:00:01に変更
        ),
      ];
    });

    test('should create email body with pins', () {
      final body = emailService.createEmailBody(testPins);
      
      expect(body, contains('地図上のピンデータ:'));
      expect(body, contains('ピンID: pin1'));
      expect(body, contains('ピンID: pin2'));
      expect(body, contains('緯度: 35.6762'));
      expect(body, contains('経度: 139.6503'));
      expect(body, contains('緯度: 36.0'));
      expect(body, contains('経度: 140.0'));
    });

    test('should create email body for empty pins', () {
      final body = emailService.createEmailBody([]);
      
      expect(body, 'ピンデータがありません。');
    });

    test('should create email body for single pin', () {
      final singlePin = [testPins.first];
      final body = emailService.createEmailBody(singlePin);
      
      expect(body, contains('ピンID: pin1'));
      expect(body, isNot(contains('ピンID: pin2')));
    });

    test('should filter new pins correctly', () {
      final now = DateTime(2024, 1, 1, 14, 0, 0); // 13:00の1時間後
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      
      final newPins = emailService.getNewPins(testPins, oneHourAgo);
      
      // pin2は13:00に作成され、14:00の1時間前（13:00）より後なので含まれる
      expect(newPins.length, 1);
      expect(newPins.first.id, 'pin2');
    });

    test('should return empty list when no new pins', () {
      final now = DateTime(2024, 1, 1, 15, 0, 0); // 13:00の2時間後
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      
      final newPins = emailService.getNewPins(testPins, twoHoursAgo);
      
      expect(newPins, isEmpty);
    });

    test('should handle edge case for time filtering', () {
      final exactTime = DateTime(2024, 1, 1, 13, 0, 0); // pin2の作成時刻と完全に一致
      
      final newPins = emailService.getNewPins(testPins, exactTime);
      
      // isAfterは厳密に「より後」なので、同じ時刻は含まれない
      expect(newPins, isEmpty);
    });

    test('should format email body with proper structure', () {
      final body = emailService.createEmailBody(testPins);
      final lines = body.split('\n');
      
      expect(lines[0], '地図上のピンデータ:');
      expect(lines[1], ''); // 空行
      expect(lines[2], 'ピンID: pin1');
      expect(lines[3], '緯度: 35.6762');
      expect(lines[4], '経度: 139.6503');
      expect(lines[5], '作成日時: 2024-01-01 12:00:00.000');
      expect(lines[6], '---');
    });
  });
}
