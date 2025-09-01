class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isImportant;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isImportant = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isImportant': isImportant,
    };
  }

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isImportant: json['isImportant'] as bool? ?? false,
    );
  }

  Announcement copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? isImportant,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
