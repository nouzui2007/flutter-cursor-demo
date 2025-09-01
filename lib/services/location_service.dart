import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  static final Location _location = Location();

  /// 位置情報の許可状態を確認
  static Future<permission_handler.PermissionStatus> checkPermission() async {
    return await permission_handler.Permission.location.status;
  }

  /// 位置情報の許可を要求
  static Future<permission_handler.PermissionStatus> requestPermission() async {
    return await permission_handler.Permission.location.request();
  }

  /// 位置情報の許可が必要かどうかを確認
  static Future<bool> needsLocationPermission() async {
    permission_handler.PermissionStatus status = await checkPermission();
    return status.isDenied || status.isRestricted;
  }

  /// 位置情報の許可が永続的に拒否されているかどうかを確認
  static Future<bool> isPermanentlyDenied() async {
    permission_handler.PermissionStatus status = await checkPermission();
    return status.isPermanentlyDenied;
  }

  /// 位置情報サービスが有効かどうかを確認
  static Future<bool> isLocationServiceEnabled() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      return serviceEnabled;
    } catch (e) {
      return false;
    }
  }

  /// 現在位置を取得
  static Future<LatLng?> getCurrentLatLng() async {
    try {
      // 位置情報の許可状態を確認
      permission_handler.PermissionStatus permissionStatus = await checkPermission();
      
      if (permissionStatus.isDenied) {
        // 許可が拒否されている場合は許可を要求
        permissionStatus = await requestPermission();
        if (permissionStatus.isDenied) {
          return null; // 許可が拒否された
        }
      }
      
      if (permissionStatus.isPermanentlyDenied) {
        return null; // 永続的に拒否された
      }
      
      // 位置情報サービスが有効かチェック
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        return null; // 位置情報サービスが無効
      }
      
      // 現在位置を取得
      LocationData locationData = await _location.getLocation();
      
      return LatLng(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      print('位置情報の取得に失敗: $e');
      return null;
    }
  }

  /// 位置情報の許可状態をチェック（Google Maps用）
  static Future<bool> isLocationPermissionGranted() async {
    permission_handler.PermissionStatus status = await checkPermission();
    return status.isGranted;
  }
}
