# Flutter Map Application

地図上でピンを管理し、位置情報を活用するFlutterアプリケーションです。

## セットアップ

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. APIキーの設定

#### Android
1. `android/app/build.gradle`の`manifestPlaceholders`を確認
2. 環境変数`GOOGLE_MAPS_API_KEY`を設定するか、直接値を設定

```bash
export GOOGLE_MAPS_API_KEY="your_actual_api_key_here"
```

#### iOS
1. `ios/Runner/Info.plist`の`GOOGLE_MAPS_API_KEY`を実際のAPIキーに変更
2. または、Xcodeで環境変数を設定

### 3. アプリの実行

```bash
# デバッグモードで実行
flutter run

# 特定のデバイスで実行
flutter run -d <device_id>
```

## 機能

- 🗺️ Google Maps統合
- 📍 現在位置の表示
- 📌 カスタムピンの管理
- 📧 ピンデータのメール送信
- 🏠 お知らせ表示
- 🔌 API接続機能

## 注意事項

- `config/api_keys.dart`ファイルはGitにコミットしないでください
- 実際のAPIキーは環境変数や設定ファイルで管理してください
- 本番環境では適切なセキュリティ対策を実施してください

## トラブルシューティング

### メールアプリが起動しない
- AndroidManifest.xmlのクエリ権限を確認
- デバイスにメールアプリがインストールされているか確認

### 地図が表示されない
- Google Maps APIキーが正しく設定されているか確認
- インターネット接続を確認

### 位置情報が取得できない
- 位置情報の許可を確認
- 位置情報サービスが有効か確認
