import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/api_service.dart';
import 'package:flutter_application_1/models/api_item.dart';

void main() {
  group('ApiService Tests', () {
    group('Filtering Tests', () {
      late List<ApiItem> testItems;

      setUp(() {
        testItems = [
          ApiItem(
            id: 1,
            name: 'アイテム1',
            description: '説明1',
            category: 'カテゴリA',
            price: 1000,
            createdAt: DateTime(2024, 1, 1),
          ),
          ApiItem(
            id: 2,
            name: 'アイテム2',
            description: '説明2',
            category: 'カテゴリB',
            price: 2000,
            createdAt: DateTime(2024, 1, 2),
          ),
          ApiItem(
            id: 3,
            name: 'アイテム3',
            description: '説明3',
            category: 'カテゴリA',
            price: 1500,
            createdAt: DateTime(2024, 1, 3),
          ),
        ];
      });

      test('should filter by category correctly', () {
        final filteredItems = ApiService.filterByCategory(testItems, 'カテゴリA');
        
        expect(filteredItems.length, 2);
        expect(filteredItems.every((item) => item.category == 'カテゴリA'), isTrue);
      });

      test('should return all items when category is empty', () {
        final filteredItems = ApiService.filterByCategory(testItems, '');
        
        expect(filteredItems.length, testItems.length);
      });

      test('should return empty list for non-existent category', () {
        final filteredItems = ApiService.filterByCategory(testItems, 'カテゴリC');
        
        expect(filteredItems, isEmpty);
      });
    });

    group('Sorting Tests', () {
      late List<ApiItem> testItems;

      setUp(() {
        testItems = [
          ApiItem(
            id: 1,
            name: 'アイテム1',
            description: '説明1',
            category: 'カテゴリA',
            price: 2000,
            createdAt: DateTime(2024, 1, 1),
          ),
          ApiItem(
            id: 2,
            name: 'アイテム2',
            description: '説明2',
            category: 'カテゴリB',
            price: 1000,
            createdAt: DateTime(2024, 1, 2),
          ),
          ApiItem(
            id: 3,
            name: 'アイテム3',
            description: '説明3',
            category: 'カテゴリA',
            price: 1500,
            createdAt: DateTime(2024, 1, 3),
          ),
        ];
      });

      test('should sort by price in ascending order', () {
        final sortedItems = ApiService.sortByPrice(testItems, ascending: true);
        
        expect(sortedItems[0].price, 1000);
        expect(sortedItems[1].price, 1500);
        expect(sortedItems[2].price, 2000);
      });

      test('should sort by price in descending order', () {
        final sortedItems = ApiService.sortByPrice(testItems, ascending: false);
        
        expect(sortedItems[0].price, 2000);
        expect(sortedItems[1].price, 1500);
        expect(sortedItems[2].price, 1000);
      });

      test('should not modify original list', () {
        final originalPrices = testItems.map((item) => item.price).toList();
        ApiService.sortByPrice(testItems, ascending: true);
        
        expect(testItems.map((item) => item.price).toList(), originalPrices);
      });
    });

    group('Search Tests', () {
      late List<ApiItem> testItems;

      setUp(() {
        testItems = [
          ApiItem(
            id: 1,
            name: 'Apple iPhone',
            description: 'スマートフォン',
            category: 'カテゴリA',
            price: 1000,
            createdAt: DateTime(2024, 1, 1),
          ),
          ApiItem(
            id: 2,
            name: 'Samsung Galaxy',
            description: 'Androidスマートフォン',
            category: 'カテゴリB',
            price: 2000,
            createdAt: DateTime(2024, 1, 2),
          ),
          ApiItem(
            id: 3,
            name: 'Google Pixel',
            description: 'Google製スマートフォン',
            category: 'カテゴリA',
            price: 1500,
            createdAt: DateTime(2024, 1, 3),
          ),
        ];
      });

      test('should search by name correctly', () {
        final searchResults = ApiService.searchByName(testItems, 'iPhone');
        
        expect(searchResults.length, 1);
        expect(searchResults.first.name, 'Apple iPhone');
      });

      test('should search by description correctly', () {
        final searchResults = ApiService.searchByName(testItems, 'Android');
        
        expect(searchResults.length, 1);
        expect(searchResults.first.name, 'Samsung Galaxy');
      });

      test('should search case-insensitively', () {
        final searchResults = ApiService.searchByName(testItems, 'iphone');
        
        expect(searchResults.length, 1);
        expect(searchResults.first.name, 'Apple iPhone');
      });

      test('should return all items when search query is empty', () {
        final searchResults = ApiService.searchByName(testItems, '');
        
        expect(searchResults.length, testItems.length);
      });

      test('should return empty list for non-matching query', () {
        final searchResults = ApiService.searchByName(testItems, 'NonExistent');
        
        expect(searchResults, isEmpty);
      });
    });

    group('Category Tests', () {
      late List<ApiItem> testItems;

      setUp(() {
        testItems = [
          ApiItem(
            id: 1,
            name: 'アイテム1',
            description: '説明1',
            category: 'カテゴリB',
            price: 1000,
            createdAt: DateTime(2024, 1, 1),
          ),
          ApiItem(
            id: 2,
            name: 'アイテム2',
            description: '説明2',
            category: 'カテゴリA',
            price: 2000,
            createdAt: DateTime(2024, 1, 2),
          ),
          ApiItem(
            id: 3,
            name: 'アイテム3',
            description: '説明3',
            category: 'カテゴリC',
            price: 1500,
            createdAt: DateTime(2024, 1, 3),
          ),
        ];
      });

      test('should return unique categories', () {
        final categories = ApiService.getAvailableCategories(testItems);
        
        expect(categories.length, 3);
        expect(categories.contains('カテゴリA'), isTrue);
        expect(categories.contains('カテゴリB'), isTrue);
        expect(categories.contains('カテゴリC'), isTrue);
      });

      test('should return sorted categories', () {
        final categories = ApiService.getAvailableCategories(testItems);
        
        expect(categories[0], 'カテゴリA');
        expect(categories[1], 'カテゴリB');
        expect(categories[2], 'カテゴリC');
      });

      test('should handle empty list', () {
        final categories = ApiService.getAvailableCategories([]);
        
        expect(categories, isEmpty);
      });
    });
  });
}
