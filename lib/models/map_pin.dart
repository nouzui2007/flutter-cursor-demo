class MapPin {
  final String id;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  MapPin({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MapPin.fromJson(Map<String, dynamic> json) {
    return MapPin(
      id: json['id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  MapPin copyWith({
    String? id,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return MapPin(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
