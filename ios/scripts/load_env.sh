#!/bin/bash

# .envファイルからAPIキーを読み込み、環境変数として設定するスクリプト
# このスクリプトはXcodeのビルドフェーズで実行されます

# SRCROOTが設定されていない場合は現在のディレクトリから推測
if [ -z "$SRCROOT" ]; then
    SRCROOT="$(dirname "$0")/.."
fi

ENV_FILE="${SRCROOT}/../.env"
INFO_PLIST="${SRCROOT}/Runner/Info.plist"
PLACEHOLDER="YOUR_GOOGLE_MAPS_API_KEY_HERE"

echo "Loading environment variables from: $ENV_FILE"

# ビルド終了時のクリーンアップ関数（ビルド完了後のみ実行）
cleanup() {
    # ビルドが完了している場合のみクリーンアップを実行
    if [ "$CONFIGURATION" = "Release" ] || [ "$EFFECTIVE_PLATFORM_NAME" = "iphoneos" ]; then
        echo "🔄 Build completed, restoring Info.plist to placeholder value..."
        if [ -f "$INFO_PLIST" ]; then
            /usr/libexec/PlistBuddy -c "Set :GOOGLE_MAPS_API_KEY $PLACEHOLDER" "$INFO_PLIST"
            echo "✅ Restored Info.plist to placeholder"
        fi
    else
        echo "ℹ️  Debug build - keeping API key for development"
    fi
}

# スクリプト終了時にクリーンアップを実行（条件付き）
trap cleanup EXIT

if [ -f "$ENV_FILE" ]; then
    # .envファイルからGOOGLE_MAPS_API_KEYを読み込み
    API_KEY=$(grep -E "^GOOGLE_MAPS_API_KEY=" "$ENV_FILE" | cut -d '=' -f2 | tr -d '\r\n')
    
    if [ -n "$API_KEY" ] && [ "$API_KEY" != "$PLACEHOLDER" ]; then
        # 環境変数として設定
        export GOOGLE_MAPS_API_KEY="$API_KEY"
        echo "✅ Google Maps API Key loaded from .env file"
        echo "API Key: ${API_KEY:0:10}..."
        
        # Info.plistの値を更新
        if [ -f "$INFO_PLIST" ]; then
            /usr/libexec/PlistBuddy -c "Set :GOOGLE_MAPS_API_KEY $API_KEY" "$INFO_PLIST"
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
