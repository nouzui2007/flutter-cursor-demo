import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  /// 位置情報の許可状態を確認
  static Future<PermissionStatus> checkPermission() async {
    return await Permission.location.status;
  }

  /// 位置情報の許可を要求
  static Future<PermissionStatus> requestPermission() async {
    return await Permission.location.request();
  }

  /// 位置情報の許可が必要かどうかを確認
  static Future<bool> needsLocationPermission() async {
    PermissionStatus status = await checkPermission();
    return status.isDenied || status.isRestricted;
  }

  /// 位置情報の許可が永続的に拒否されているかどうかを確認
  static Future<bool> isPermanentlyDenied() async {
    PermissionStatus status = await checkPermission();
    return status.isPermanentlyDenied;
  }

  /// 位置情報サービスが有効かどうかを確認
  static Future<bool> isLocationServiceEnabled() async {
    // 許可状態で判断（簡易的な実装）
    PermissionStatus status = await checkPermission();
    return status.isGranted;
  }

  /// 現在位置を取得
  /// 注意: このメソッドは実際の位置情報を返しません
  /// Google MapsのmyLocationEnabledを使用して現在位置を表示してください
  static Future<LatLng?> getCurrentLatLng() async {
    // 実際の実装では、プラットフォーム固有の位置情報取得APIを使用
    // または、Google Mapsの現在位置機能を活用
    
    // 現在は固定位置（東京）を返す
    // 実際のアプリでは、Google Mapsの現在位置ボタンを使用することを推奨
    return const LatLng(35.6762, 139.6503);
  }

  /// 位置情報の許可状態をチェック（Google Maps用）
  static Future<bool> isLocationPermissionGranted() async {
    PermissionStatus status = await checkPermission();
    return status.isGranted;
  }
}
