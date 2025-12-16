#!/usr/bin/env bash
set -e

REGION="$1"

# Configuration Recorder を確認
recorder_count=$(aws configservice describe-configuration-recorders --region "$REGION" --query "ConfigurationRecorders | length(@)" --output text)
recorder_exists="false"
if [ "$recorder_count" -gt 0 ]; then
  recorder_exists="true"
fi

# Delivery Channel を確認
channel_count=$(aws configservice describe-delivery-channels --region "$REGION" --query "DeliveryChannels | length(@)" --output text)
channel_exists="false"
if [ "$channel_count" -gt 0 ]; then
  channel_exists="true"
fi

# 両方存在するかどうかを判定
config_exists="false"
if [ "$recorder_exists" = "true" ] && [ "$channel_exists" = "true" ]; then
  config_exists="true"
fi

# JSON 形式で出力
echo "{\"recorder_exists\": \"$recorder_exists\", \"delivery_channel_exists\": \"$channel_exists\", \"config_exists\": \"$config_exists\"}"