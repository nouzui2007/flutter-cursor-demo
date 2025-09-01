class ApiItem {
  final int id;
  final String name;
  final String description;
  final String category;
  final int price;
  final DateTime createdAt;

  const ApiItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ApiItem.fromJson(Map<String, dynamic> json) {
    return ApiItem(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ApiItem copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    int? price,
    DateTime? createdAt,
  }) {
    return ApiItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ApiResponse {
  final bool success;
  final List<ApiItem> data;
  final int total;
  final int returned;
  final DateTime timestamp;

  const ApiResponse({
    required this.success,
    required this.data,
    required this.total,
    required this.returned,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
      'total': total,
      'returned': returned,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((item) => ApiItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      returned: json['returned'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
