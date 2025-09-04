import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/api_item.dart';
import '../services/api_service.dart';

class ApiConnectionScreen extends StatefulWidget {
  const ApiConnectionScreen({super.key});

  @override
  State<ApiConnectionScreen> createState() => _ApiConnectionScreenState();
}

class _ApiConnectionScreenState extends State<ApiConnectionScreen> {
  ApiResponse? _apiResponse;
  List<ApiItem> _displayedItems = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.fetchData();
      if (response != null) {
        setState(() {
          _apiResponse = response;
          _displayedItems = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'データの取得に失敗しました';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'エラー: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    if (_apiResponse == null) return;

    var filteredItems = _apiResponse!.data;

    // カテゴリフィルター
    if (_selectedCategory.isNotEmpty) {
      filteredItems = ApiService.filterByCategory(filteredItems, _selectedCategory);
    }

    // 検索フィルター
    if (_searchQuery.isNotEmpty) {
      filteredItems = ApiService.searchByName(filteredItems, _searchQuery);
    }

    // ソート
    filteredItems = ApiService.sortByPrice(filteredItems, ascending: _sortAscending);

    setState(() {
      _displayedItems = filteredItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API接続'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'データを更新',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    if (_apiResponse == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // 検索バー
          TextField(
            decoration: const InputDecoration(
              hintText: 'アイテム名または説明で検索...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // カテゴリフィルター
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'カテゴリ',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('すべて'),
                    ),
                    ...ApiService.getAvailableCategories(_apiResponse!.data)
                        .map((category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ))
                        ,
                  ],
                  onChanged: (value) {
                    _selectedCategory = value ?? '';
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              // ソートボタン
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                  _applyFilters();
                },
                icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                label: Text(_sortAscending ? '価格昇順' : '価格降順'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('データを取得中...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (_apiResponse == null) {
      return const Center(
        child: Text('データがありません'),
      );
    }

    if (_displayedItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '条件に一致するアイテムがありません',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 統計情報
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('総数', _apiResponse!.total.toString()),
              _buildStatItem('表示中', _displayedItems.length.toString()),
              _buildStatItem('カテゴリ', ApiService.getAvailableCategories(_apiResponse!.data).length.toString()),
            ],
          ),
        ),
        // アイテムリスト
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _displayedItems.length,
            itemBuilder: (context, index) {
              final item = _displayedItems[index];
              return _buildItemCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(ApiItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '¥${NumberFormat('#,###').format(item.price)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  DateFormat('yyyy/MM/dd').format(item.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'カテゴリA':
        return Colors.blue;
      case 'カテゴリB':
        return Colors.green;
      case 'カテゴリC':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
