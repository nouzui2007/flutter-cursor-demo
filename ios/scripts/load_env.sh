#!/bin/bash

# .envファイルからAPIキーを読み込み、環境変数として設定するスクリプト
# このスクリプトはXcodeのビルドフェーズで実行されます

ENV_FILE="${SRCROOT}/../.env"

echo "Loading environment variables from: $ENV_FILE"

if [ -f "$ENV_FILE" ]; then
    # .envファイルからGOOGLE_MAPS_API_KEYを読み込み
    API_KEY=$(grep -E "^GOOGLE_MAPS_API_KEY=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '\r\n')
    
    if [ -n "$API_KEY" ] && [ "$API_KEY" != "YOUR_GOOGLE_MAPS_API_KEY_HERE" ]; then
        # 環境変数として設定
        export GOOGLE_MAPS_API_KEY="$API_KEY"
        echo "✅ Google Maps API Key loaded from .env file"
        echo "API Key: ${API_KEY:0:10}..."
        
        # Info.plistの値を更新
        if [ -f "${SRCROOT}/Runner/Info.plist" ]; then
            /usr/libexec/PlistBuddy -c "Set :GOOGLE_MAPS_API_KEY $API_KEY" "${SRCROOT}/Runner/Info.plist"
            echo "✅ Updated Info.plist with API key"
        fi
    else
        echo "❌ GOOGLE_MAPS_API_KEY not found or invalid in .env file"
        echo "Current value: '$API_KEY'"
        exit 1
    fi
else
    echo "❌ .env file not found at $ENV_FILE"
    exit 1
fi
