import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps APIキーを設定
    // 本番環境では環境変数や設定ファイルから読み込む
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String ?? "YOUR_GOOGLE_MAPS_API_KEY_HERE"
    
    // APIキーが有効な場合のみGoogle Mapsサービスを初期化
    if apiKey != "YOUR_GOOGLE_MAPS_API_KEY_HERE" && !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    } else {
      print("警告: Google Maps APIキーが設定されていません。地図機能は使用できません。")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
