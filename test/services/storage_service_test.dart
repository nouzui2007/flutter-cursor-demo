import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/storage_service.dart';
import 'package:flutter_application_1/models/map_pin.dart';
import '../setup_test.dart';

void main() {
  setUpAll(() async {
    await TestSetup.setupTestEnvironment();
  });
  
  group('StorageService Tests', () {
    late StorageService storageService;
    late MapPin testPin;

    setUp(() async {
      storageService = StorageService();
      testPin = MapPin(
        id: 'test_id',
        latitude: 35.6762,
        longitude: 139.6503,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );
      
      // 各テストの前にデータをクリア
      await storageService.savePins([]);
      await storageService.saveEmail('');
    });

    test('should save and load pins correctly', () async {
      final pins = [testPin];
      
      await storageService.savePins(pins);
      final loadedPins = await storageService.loadPins();
      
      expect(loadedPins.length, 1);
      expect(loadedPins.first.id, testPin.id);
      expect(loadedPins.first.latitude, testPin.latitude);
      expect(loadedPins.first.longitude, testPin.longitude);
    });

    test('should add pin correctly', () async {
      await storageService.addPin(testPin);
      final loadedPins = await storageService.loadPins();
      
      expect(loadedPins.length, 1);
      expect(loadedPins.first.id, testPin.id);
    });

    test('should remove pin correctly', () async {
      // まずピンを追加
      await storageService.addPin(testPin);
      var loadedPins = await storageService.loadPins();
      expect(loadedPins.length, 1);
      
      // ピンを削除
      await storageService.removePin(testPin.id);
      loadedPins = await storageService.loadPins();
      expect(loadedPins.length, 0);
    });

    test('should handle empty pins list', () async {
      final emptyPins = <MapPin>[];
      await storageService.savePins(emptyPins);
      final loadedPins = await storageService.loadPins();
      
      expect(loadedPins, isEmpty);
    });

    test('should save and load email correctly', () async {
      const testEmail = 'test@example.com';
      
      await storageService.saveEmail(testEmail);
      final loadedEmail = await storageService.loadEmail();
      
      expect(loadedEmail, testEmail);
    });

    test('should return empty string for non-existent email', () async {
      final loadedEmail = await storageService.loadEmail();
      expect(loadedEmail, '');
    });

    test('should handle multiple pins operations', () async {
      final pin1 = MapPin(
        id: 'pin1',
        latitude: 35.6762,
        longitude: 139.6503,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );
      
      final pin2 = MapPin(
        id: 'pin2',
        latitude: 36.0,
        longitude: 140.0,
        createdAt: DateTime(2024, 1, 1, 13, 0, 0),
      );

      // 複数のピンを追加
      await storageService.addPin(pin1);
      await storageService.addPin(pin2);
      
      var loadedPins = await storageService.loadPins();
      expect(loadedPins.length, 2);
      
      // 1つ削除
      await storageService.removePin(pin1.id);
      loadedPins = await storageService.loadPins();
      expect(loadedPins.length, 1);
      expect(loadedPins.first.id, pin2.id);
    });
  });
}
