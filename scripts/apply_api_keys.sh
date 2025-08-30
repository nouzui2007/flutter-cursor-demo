#!/bin/bash

# APIキーを適用するスクリプト
# 使用方法: ./scripts/apply_api_keys.sh

# ローカル設定ファイルからAPIキーを読み込み
if [ -f "config/api_keys_local.dart" ]; then
    API_KEY=$(grep "googleMapsApiKey = " config/api_keys_local.dart | sed "s/.*'\(.*\)'.*/\1/")
else
    echo "Error: config/api_keys_local.dart not found"
    echo "Please create this file with your API key"
    exit 1
fi

if [ -z "$API_KEY" ]; then
    echo "Error: API key not found in config/api_keys_local.dart"
    exit 1
fi

echo "Applying Google Maps API key: $API_KEY"

# AndroidManifest.xmlを更新
sed -i '' "s/YOUR_GOOGLE_MAPS_API_KEY_HERE/$API_KEY/g" android/app/src/main/AndroidManifest.xml

# iOS AppDelegate.swiftを更新
sed -i '' "s/YOUR_GOOGLE_MAPS_API_KEY_HERE/$API_KEY/g" ios/Runner/AppDelegate.swift

echo "API keys applied successfully!"
