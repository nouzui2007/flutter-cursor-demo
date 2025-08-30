# Flutter Map Pin Manager

地図上でピンを管理し、メール送信機能を持つFlutterアプリケーションです。

## 機能

- Google Mapsを使用した地図表示
- 地図上でのピンの追加・削除
- ピンリストの表示と管理
- ピンデータのメール送信
- 日本語・英語の国際化対応

## セットアップ

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. Google Maps APIキーの設定

#### 方法1: 自動設定（推奨）

```bash
# スクリプトを実行してAPIキーを適用
./scripts/apply_api_keys.sh
```

#### 方法2: 手動設定

1. `config/api_keys.dart`ファイルを編集
2. `googleMapsApiKey`に実際のAPIキーを設定
3. 以下のファイルを手動で更新：
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/AppDelegate.swift`

### 3. アプリのビルド

```bash
# Android
flutter build apk --debug

# iOS
flutter build ios --debug
```

## 使用方法

1. **ピンの追加**: 地図をタップ
2. **ピンの確認**: ピンをタップして詳細表示
3. **ピンの削除**: ピン詳細ダイアログまたはピンリストから削除
4. **地図タイプ切り替え**: アプリバーの地図アイコン
5. **メール送信**: アプリバーのメールアイコンまたはフローティングアクションボタン
6. **ピンリスト表示**: 左側のリストアイコンボタン

## 開発

### テストの実行

```bash
flutter test
```

### コード分析

```bash
flutter analyze
```

## 注意事項

- `config/api_keys.dart`ファイルには実際のAPIキーが含まれています
- このファイルは`.gitignore`に含まれており、Gitにコミットされません
- 本番環境では適切な環境変数管理を使用してください

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
