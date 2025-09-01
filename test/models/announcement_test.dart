import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/announcement.dart';

void main() {
  group('Announcement Model Tests', () {
    test('should create Announcement with correct properties', () {
      final announcement = Announcement(
        id: 'test_id',
        title: 'テストタイトル',
        content: 'テストコンテンツ',
        createdAt: DateTime(2024, 12, 20, 10, 0, 0),
        isImportant: true,
      );

      expect(announcement.id, 'test_id');
      expect(announcement.title, 'テストタイトル');
      expect(announcement.content, 'テストコンテンツ');
      expect(announcement.createdAt, DateTime(2024, 12, 20, 10, 0, 0));
      expect(announcement.isImportant, true);
    });

    test('should create Announcement with default isImportant value', () {
      final announcement = Announcement(
        id: 'test_id',
        title: 'テストタイトル',
        content: 'テストコンテンツ',
        createdAt: DateTime(2024, 12, 20, 10, 0, 0),
      );

      expect(announcement.isImportant, false);
    });

    test('should convert Announcement to JSON and back', () {
      final originalAnnouncement = Announcement(
        id: 'test_id',
        title: 'テストタイトル',
        content: 'テストコンテンツ',
        createdAt: DateTime(2024, 12, 20, 10, 0, 0),
        isImportant: true,
      );

      final json = originalAnnouncement.toJson();
      final restoredAnnouncement = Announcement.fromJson(json);

      expect(restoredAnnouncement.id, originalAnnouncement.id);
      expect(restoredAnnouncement.title, originalAnnouncement.title);
      expect(restoredAnnouncement.content, originalAnnouncement.content);
      expect(restoredAnnouncement.createdAt, originalAnnouncement.createdAt);
      expect(restoredAnnouncement.isImportant, originalAnnouncement.isImportant);
    });

    test('should create copy of Announcement with updated values', () {
      final originalAnnouncement = Announcement(
        id: 'test_id',
        title: 'テストタイトル',
        content: 'テストコンテンツ',
        createdAt: DateTime(2024, 12, 20, 10, 0, 0),
        isImportant: false,
      );

      final updatedAnnouncement = originalAnnouncement.copyWith(
        title: '更新されたタイトル',
        isImportant: true,
      );

      expect(updatedAnnouncement.id, originalAnnouncement.id);
      expect(updatedAnnouncement.title, '更新されたタイトル');
      expect(updatedAnnouncement.content, originalAnnouncement.content);
      expect(updatedAnnouncement.createdAt, originalAnnouncement.createdAt);
      expect(updatedAnnouncement.isImportant, true);
    });

    test('should handle JSON parsing errors gracefully', () {
      final invalidJson = {
        'id': 'test_id',
        'title': 'テストタイトル',
        'content': 'テストコンテンツ',
        'createdAt': 'invalid_date', // 無効な日付形式
        'isImportant': 'invalid_boolean', // 無効なブール値
      };

      expect(() => Announcement.fromJson(invalidJson), throwsA(isA<FormatException>()));
    });
  });
}
