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
    // まず現在の状態を確認
    var status = await permission_handler.Permission.location.status;
    
    if (status.isPermanentlyDenied) {
      // 永続的に拒否されている場合は設定を開く
      await openAppSettings();
      return await permission_handler.Permission.location.status;
    }
    
    // 通常の許可要求
    status = await permission_handler.Permission.location.request();
    
    // 拒否された場合は再度確認
    if (status.isDenied) {
      status = await permission_handler.Permission.location.request();
    }
    
    return status;
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
      print('🔍 LocationService: 現在位置取得を開始...');
      
      // 位置情報の許可状態を確認
      permission_handler.PermissionStatus permissionStatus = await checkPermission();
      print('📋 LocationService: 許可状態: $permissionStatus');
      
      if (permissionStatus.isDenied) {
        print('⚠️ LocationService: 許可が拒否されています。許可を要求します...');
        // 許可が拒否されている場合は許可を要求
        permissionStatus = await requestPermission();
        print('📋 LocationService: 許可要求後の状態: $permissionStatus');
        if (permissionStatus.isDenied) {
          print('❌ LocationService: 許可が拒否されました');
          return null; // 許可が拒否された
        }
      }
      
      if (permissionStatus.isPermanentlyDenied) {
        print('❌ LocationService: 永続的に拒否されています');
        return null; // 永続的に拒否された
      }
      
      // 位置情報サービスが有効かチェック
      bool serviceEnabled = await _location.serviceEnabled();
      print('📍 LocationService: 位置情報サービス有効: $serviceEnabled');
      if (!serviceEnabled) {
        print('❌ LocationService: 位置情報サービスが無効です');
        return null; // 位置情報サービスが無効
      }
      
      // 現在位置を取得
      print('🎯 LocationService: 位置データを取得中...');
      LocationData locationData = await _location.getLocation();
      print('📍 LocationService: 取得した位置データ: lat=${locationData.latitude}, lng=${locationData.longitude}');
      
      if (locationData.latitude != null && locationData.longitude != null) {
        LatLng result = LatLng(locationData.latitude!, locationData.longitude!);
        print('✅ LocationService: 位置情報取得成功: $result');
        return result;
      } else {
        print('❌ LocationService: 位置データがnullです');
        return null;
      }
    } catch (e) {
      print('❌ LocationService: 位置情報の取得に失敗: $e');
      return null;
    }
  }

  /// 位置情報の許可状態をチェック（Google Maps用）
  static Future<bool> isLocationPermissionGranted() async {
    permission_handler.PermissionStatus status = await checkPermission();
    return status.isGranted;
  }
}
