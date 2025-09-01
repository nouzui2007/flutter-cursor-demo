# Flutter Map Application

地図上でピンを管理し、位置情報を活用するFlutterアプリケーションです。

## セットアップ

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. APIキーの設定

1. `.env.sample`をコピーして`.env`ファイルを作成
2. `.env`ファイルにGoogle Maps APIキーを設定

```bash
# .env.sampleをコピー
cp .env.sample .env

# .envファイルを編集してAPIキーを設定
# GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

#### iOS用の追加設定
iOSビルド前に以下のスクリプトを実行してください：

```bash
# .envファイルからInfo.plistにAPIキーを設定
./ios/scripts/load_env.sh
```

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

- `.env`ファイルはGitにコミットしないでください（`.gitignore`に含まれています）
- 実際のAPIキーは`.env`ファイルで管理してください
- 本番環境では適切なセキュリティ対策を実施してください
- iOS開発時は`./ios/scripts/load_env.sh`を実行してAPIキーを設定してください

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
