import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/map_pin.dart';

void main() {
  group('MapPin Model Tests', () {
    test('should create MapPin with correct properties', () {
      final pin = MapPin(
        id: 'test_id',
        latitude: 35.6762,
        longitude: 139.6503,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      expect(pin.id, 'test_id');
      expect(pin.latitude, 35.6762);
      expect(pin.longitude, 139.6503);
      expect(pin.createdAt, DateTime(2024, 1, 1, 12, 0, 0));
    });

    test('should convert MapPin to JSON and back', () {
      final originalPin = MapPin(
        id: 'test_id',
        latitude: 35.6762,
        longitude: 139.6503,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = originalPin.toJson();
      final restoredPin = MapPin.fromJson(json);

      expect(restoredPin.id, originalPin.id);
      expect(restoredPin.latitude, originalPin.latitude);
      expect(restoredPin.longitude, originalPin.longitude);
      expect(restoredPin.createdAt, originalPin.createdAt);
    });

    test('should create copy of MapPin with updated values', () {
      final originalPin = MapPin(
        id: 'test_id',
        latitude: 35.6762,
        longitude: 139.6503,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final updatedPin = originalPin.copyWith(
        latitude: 36.0,
        longitude: 140.0,
      );

      expect(updatedPin.id, originalPin.id);
      expect(updatedPin.latitude, 36.0);
      expect(updatedPin.longitude, 140.0);
      expect(updatedPin.createdAt, originalPin.createdAt);
    });

    test('should handle JSON parsing errors gracefully', () {
      final invalidJson = {
        'id': 'test_id',
        'latitude': 'invalid_latitude', // 文字列で数値が必要
        'longitude': 139.6503,
        'createdAt': 'invalid_date', // 無効な日付形式
      };

      expect(() => MapPin.fromJson(invalidJson), throwsA(isA<FormatException>()));
    });
  });
}
