#!/bin/bash

# APIキーを適用するスクリプト
# 使用方法: ./scripts/apply_api_keys.sh

# .envファイルからAPIキーを読み込み
if [ -f ".env" ]; then
    # .envファイルからGOOGLE_MAPS_API_KEYを読み込み
    export $(cat .env | xargs)
    API_KEY=$GOOGLE_MAPS_API_KEY
else
    echo "Error: .env file not found"
    echo "Please create .env file with GOOGLE_MAPS_API_KEY=your_api_key"
    exit 1
fi

if [ -z "$API_KEY" ]; then
    echo "Error: GOOGLE_MAPS_API_KEY not found in .env file"
    exit 1
fi

echo "Applying Google Maps API key: $API_KEY"

# AndroidManifest.xmlを更新
sed -i '' "s/YOUR_GOOGLE_MAPS_API_KEY_HERE/$API_KEY/g" android/app/src/main/AndroidManifest.xml

# iOS AppDelegate.swiftを更新
sed -i '' "s/YOUR_GOOGLE_MAPS_API_KEY_HERE/$API_KEY/g" ios/Runner/AppDelegate.swift

echo "API keys applied successfully!"
