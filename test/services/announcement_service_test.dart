import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/announcement_service.dart';
import 'package:flutter_application_1/models/announcement.dart';

void main() {
  group('AnnouncementService Tests', () {
    group('Dummy Data Tests', () {
      test('should return dummy announcements', () {
        final announcements = AnnouncementService.getDummyAnnouncements();
        
        expect(announcements, isNotEmpty);
        expect(announcements.length, 4);
      });

      test('should have correct announcement properties', () {
        final announcements = AnnouncementService.getDummyAnnouncements();
        final firstAnnouncement = announcements.first;
        
        expect(firstAnnouncement.id, '1');
        expect(firstAnnouncement.title, 'アプリがリリースされました！');
        expect(firstAnnouncement.isImportant, true);
      });

      test('should have important announcements', () {
        final announcements = AnnouncementService.getDummyAnnouncements();
        final importantAnnouncements = announcements.where((a) => a.isImportant).toList();
        
        expect(importantAnnouncements, isNotEmpty);
        expect(importantAnnouncements.length, 1);
      });
    });

    group('Get Announcements Tests', () {
      test('should return sorted announcements', () {
        final announcements = AnnouncementService.getAnnouncements();
        
        expect(announcements, isNotEmpty);
        
        // 重要なお知らせが最初に来ることを確認
        final firstAnnouncement = announcements.first;
        expect(firstAnnouncement.isImportant, true);
      });

      test('should sort by importance and date', () {
        final announcements = AnnouncementService.getAnnouncements();
        
        // 重要なお知らせが最初
        expect(announcements.first.isImportant, true);
        
        // その他は日付順（新しい順）
        for (int i = 1; i < announcements.length - 1; i++) {
          final current = announcements[i];
          final next = announcements[i + 1];
          
          if (current.isImportant == next.isImportant) {
            expect(current.createdAt.isAfter(next.createdAt) || 
                   current.createdAt.isAtSameMomentAs(next.createdAt), isTrue);
          }
        }
      });
    });

    group('Important Announcements Tests', () {
      test('should return only important announcements', () {
        final importantAnnouncements = AnnouncementService.getImportantAnnouncements();
        
        expect(importantAnnouncements, isNotEmpty);
        expect(importantAnnouncements.length, 1);
        
        for (final announcement in importantAnnouncements) {
          expect(announcement.isImportant, true);
        }
      });

      test('should filter important announcements correctly', () {
        final allAnnouncements = AnnouncementService.getDummyAnnouncements();
        final importantCount = allAnnouncements.where((a) => a.isImportant).length;
        final importantAnnouncements = AnnouncementService.getImportantAnnouncements();
        
        expect(importantAnnouncements.length, importantCount);
      });
    });

    group('Data Consistency Tests', () {
      test('should maintain data consistency across calls', () {
        final announcements1 = AnnouncementService.getAnnouncements();
        final announcements2 = AnnouncementService.getAnnouncements();
        
        expect(announcements1.length, announcements2.length);
        
        for (int i = 0; i < announcements1.length; i++) {
          expect(announcements1[i].id, announcements2[i].id);
          expect(announcements1[i].title, announcements2[i].title);
          expect(announcements1[i].content, announcements2[i].content);
          expect(announcements1[i].isImportant, announcements2[i].isImportant);
        }
      });

      test('should have unique IDs', () {
        final announcements = AnnouncementService.getDummyAnnouncements();
        final ids = announcements.map((a) => a.id).toSet();
        
        expect(ids.length, announcements.length);
      });
    });
  });
}
