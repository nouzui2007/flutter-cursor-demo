#!/bin/bash

# .envファイルからAPIキーを読み込み、環境変数として設定するスクリプト
# このスクリプトはXcodeのビルドフェーズで実行されます

ENV_FILE="${SRCROOT}/../../.env"

if [ -f "$ENV_FILE" ]; then
    # .envファイルからGOOGLE_MAPS_API_KEYを読み込み
    API_KEY=$(grep -E "^GOOGLE_MAPS_API_KEY=" "$ENV_FILE" | cut -d '=' -f2)
    
    if [ -n "$API_KEY" ]; then
        # 環境変数として設定
        export GOOGLE_MAPS_API_KEY="$API_KEY"
        echo "Google Maps API Key loaded from .env file"
        echo "GOOGLE_MAPS_API_KEY=$API_KEY" >> "${SRCROOT}/env_vars.tmp"
    else
        echo "GOOGLE_MAPS_API_KEY not found in .env file"
        exit 1
    fi
else
    echo ".env file not found at $ENV_FILE"
    exit 1
fi
