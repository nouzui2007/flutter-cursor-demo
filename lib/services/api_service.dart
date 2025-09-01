import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_item.dart';

class ApiService {
  static const String _baseUrl = 'https://sample-rest-api.vercel.app/api/index.js';

  // APIからデータを取得
  static Future<ApiResponse?> fetchData() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        throw Exception('HTTPエラー: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API接続エラー: $e');
    }
  }

  // カテゴリ別にアイテムをフィルタリング
  static List<ApiItem> filterByCategory(List<ApiItem> items, String category) {
    if (category.isEmpty) return items;
    return items.where((item) => item.category == category).toList();
  }

  // 価格順にソート
  static List<ApiItem> sortByPrice(List<ApiItem> items, {bool ascending = true}) {
    final sortedItems = List<ApiItem>.from(items);
    if (ascending) {
      sortedItems.sort((a, b) => a.price.compareTo(b.price));
    } else {
      sortedItems.sort((a, b) => b.price.compareTo(a.price));
    }
    return sortedItems;
  }

  // 名前で検索
  static List<ApiItem> searchByName(List<ApiItem> items, String query) {
    if (query.isEmpty) return items;
    return items
        .where((item) => 
            item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // 利用可能なカテゴリを取得
  static List<String> getAvailableCategories(List<ApiItem> items) {
    return items.map((item) => item.category).toSet().toList()..sort();
  }
}
