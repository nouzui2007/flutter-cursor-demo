import 'package:url_launcher/url_launcher.dart';
import '../models/map_pin.dart';

class EmailService {
  // メール送信
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        final result = await launchUrl(emailUri);
        if (!result) {
          throw Exception('メールアプリの起動に失敗しました');
        }
      } else {
        throw Exception('メールアプリを起動できませんでした。デバイスにメールアプリがインストールされているか確認してください。');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('メール送信で予期しないエラーが発生しました: $e');
      }
    }
  }

  // ピンデータをメール本文に変換
  String createEmailBody(List<MapPin> pins) {
    if (pins.isEmpty) {
      return 'ピンデータがありません。';
    }

    final buffer = StringBuffer();
    buffer.writeln('地図上のピンデータ:');
    buffer.writeln('');

    for (final pin in pins) {
      buffer.writeln('ピンID: ${pin.id}');
      buffer.writeln('緯度: ${pin.latitude}');
      buffer.writeln('経度: ${pin.longitude}');
      buffer.writeln('作成日時: ${pin.createdAt.toString()}');
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  // 新規ピンのみを抽出
  List<MapPin> getNewPins(List<MapPin> allPins, DateTime since) {
    return allPins.where((pin) => pin.createdAt.isAfter(since)).toList();
  }
}
