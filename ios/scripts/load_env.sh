#!/bin/bash

# .envファイルからAPIキーを読み込み、Info.plistに設定するスクリプト

ENV_FILE="${SRCROOT}/../../.env"
PLIST_FILE="${SRCROOT}/Runner/Info.plist"

if [ -f "$ENV_FILE" ]; then
    # .envファイルからGOOGLE_MAPS_API_KEYを読み込み
    API_KEY=$(grep -E "^GOOGLE_MAPS_API_KEY=" "$ENV_FILE" | cut -d '=' -f2)
    
    if [ -n "$API_KEY" ]; then
        # Info.plistのAPIキーを更新
        /usr/libexec/PlistBuddy -c "Set :GOOGLE_MAPS_API_KEY $API_KEY" "$PLIST_FILE"
        echo "Google Maps API Key updated from .env file"
    else
        echo "GOOGLE_MAPS_API_KEY not found in .env file"
    fi
else
    echo ".env file not found at $ENV_FILE"
fi
