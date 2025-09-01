import '../models/announcement.dart';

class AnnouncementService {
  // ダミーのお知らせデータ
  static List<Announcement> getDummyAnnouncements() {
    return [
      Announcement(
        id: '1',
        title: 'アプリがリリースされました！',
        content: '地図ピン管理アプリの正式版がリリースされました。位置情報の許可機能も追加されています。',
        createdAt: DateTime(2024, 12, 20, 10, 0, 0),
        isImportant: true,
      ),
      Announcement(
        id: '2',
        title: '位置情報機能が追加されました',
        content: '現在位置の表示と、位置情報の許可要求機能が追加されました。',
        createdAt: DateTime(2024, 12, 19, 15, 30, 0),
        isImportant: false,
      ),
      Announcement(
        id: '3',
        title: 'メール送信機能について',
        content: 'ピンデータをメールで送信する機能が利用できます。',
        createdAt: DateTime(2024, 12, 18, 9, 15, 0),
        isImportant: false,
      ),
      Announcement(
        id: '4',
        title: '地図タイプの切り替え',
        content: '通常地図と衛星地図を切り替えて表示できます。',
        createdAt: DateTime(2024, 12, 17, 14, 20, 0),
        isImportant: false,
      ),
    ];
  }

  // お知らせを取得（重要度順、日付順）
  static List<Announcement> getAnnouncements() {
    final announcements = getDummyAnnouncements();
    announcements.sort((a, b) {
      // 重要なお知らせを先に表示
      if (a.isImportant != b.isImportant) {
        return b.isImportant ? 1 : -1;
      }
      // 日付順（新しい順）
      return b.createdAt.compareTo(a.createdAt);
    });
    return announcements;
  }

  // 重要なお知らせのみ取得
  static List<Announcement> getImportantAnnouncements() {
    return getDummyAnnouncements().where((a) => a.isImportant).toList();
  }
}
