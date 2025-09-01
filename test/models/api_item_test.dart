import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/api_item.dart';

void main() {
  group('ApiItem Model Tests', () {
    test('should create ApiItem with correct properties', () {
      final item = ApiItem(
        id: 1,
        name: 'テストアイテム',
        description: 'テスト説明',
        category: 'カテゴリA',
        price: 1000,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(item.id, 1);
      expect(item.name, 'テストアイテム');
      expect(item.description, 'テスト説明');
      expect(item.category, 'カテゴリA');
      expect(item.price, 1000);
      expect(item.createdAt, DateTime(2024, 1, 1));
    });

    test('should convert ApiItem to JSON and back', () {
      final originalItem = ApiItem(
        id: 1,
        name: 'テストアイテム',
        description: 'テスト説明',
        category: 'カテゴリA',
        price: 1000,
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = originalItem.toJson();
      final restoredItem = ApiItem.fromJson(json);

      expect(restoredItem.id, originalItem.id);
      expect(restoredItem.name, originalItem.name);
      expect(restoredItem.description, originalItem.description);
      expect(restoredItem.category, originalItem.category);
      expect(restoredItem.price, originalItem.price);
      expect(restoredItem.createdAt, originalItem.createdAt);
    });

    test('should create copy of ApiItem with updated values', () {
      final originalItem = ApiItem(
        id: 1,
        name: 'テストアイテム',
        description: 'テスト説明',
        category: 'カテゴリA',
        price: 1000,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedItem = originalItem.copyWith(
        name: '更新されたアイテム',
        price: 2000,
      );

      expect(updatedItem.id, originalItem.id);
      expect(updatedItem.name, '更新されたアイテム');
      expect(updatedItem.description, originalItem.description);
      expect(updatedItem.category, originalItem.category);
      expect(updatedItem.price, 2000);
      expect(updatedItem.createdAt, originalItem.createdAt);
    });
  });

  group('ApiResponse Model Tests', () {
    test('should create ApiResponse with correct properties', () {
      final items = [
        ApiItem(
          id: 1,
          name: 'アイテム1',
          description: '説明1',
          category: 'カテゴリA',
          price: 1000,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final response = ApiResponse(
        success: true,
        data: items,
        total: 1,
        returned: 1,
        timestamp: DateTime(2024, 1, 1),
      );

      expect(response.success, true);
      expect(response.data, items);
      expect(response.total, 1);
      expect(response.returned, 1);
      expect(response.timestamp, DateTime(2024, 1, 1));
    });

    test('should convert ApiResponse to JSON and back', () {
      final items = [
        ApiItem(
          id: 1,
          name: 'アイテム1',
          description: '説明1',
          category: 'カテゴリA',
          price: 1000,
          createdAt: DateTime(2024, 1, 1, 12, 0, 0),
        ),
      ];

      final originalResponse = ApiResponse(
        success: true,
        data: items,
        total: 1,
        returned: 1,
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = originalResponse.toJson();
      final restoredResponse = ApiResponse.fromJson(json);

      expect(restoredResponse.success, originalResponse.success);
      expect(restoredResponse.data.length, originalResponse.data.length);
      expect(restoredResponse.total, originalResponse.total);
      expect(restoredResponse.returned, originalResponse.returned);
      expect(restoredResponse.timestamp, originalResponse.timestamp);
    });

    test('should handle empty data list', () {
      final response = ApiResponse(
        success: true,
        data: [],
        total: 0,
        returned: 0,
        timestamp: DateTime(2024, 1, 1),
      );

      expect(response.data, isEmpty);
      expect(response.total, 0);
      expect(response.returned, 0);
    });
  });
}
