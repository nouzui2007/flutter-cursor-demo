import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

/// テスト用のセットアップファイル
/// プラグインのモックを設定し、テスト環境での動作を保証します
class TestSetup {
  static Future<void> setupTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // SharedPreferencesのテスト用設定
    SharedPreferences.setMockInitialValues({});
    
    // PermissionHandlerのテスト用設定
    // 実際のテストでは、より詳細なモックが必要になる場合があります
  }
}

/// テスト用のPermissionHandlerモック
class MockPermissionHandler {
  static Future<PermissionStatus> getLocationStatus() async {
    // テスト用の固定値を返す
    return PermissionStatus.granted;
  }
  
  static Future<PermissionStatus> requestLocationPermission() async {
    // テスト用の固定値を返す
    return PermissionStatus.granted;
  }
}

// テストファイルとして認識されるようにmain関数を追加
void main() {
  // このファイルは直接実行されず、他のテストファイルからインポートされる
}
