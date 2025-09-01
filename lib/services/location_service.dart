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
    // 実際の実装では、プラットフォーム固有のコードが必要
    // ここでは簡易的に許可状態で判断
    PermissionStatus status = await checkPermission();
    return status.isGranted;
  }

  /// 現在位置を取得（テスト用の固定値）
  /// 実際の実装では、geolocatorパッケージを使用
  static Future<LatLng?> getCurrentLatLng() async {
    // テスト用の固定位置（東京）
    // 実際の実装では以下のように実装：
    // try {
    //   final position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high,
    //   );
    //   return LatLng(position.latitude, position.longitude);
    // } catch (e) {
    //   return null;
    // }
    return const LatLng(35.6762, 139.6503);
  }
}
