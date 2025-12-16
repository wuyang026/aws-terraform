#!/usr/bin/env bash
# check_config.sh
set -e

REGION="$1"

# 检查 Configuration Recorder
recorder_count=$(aws configservice describe-configuration-recorders --region "$REGION" --query "ConfigurationRecorders | length(@)" --output text)
recorder_exists=false
if [ "$recorder_count" -gt 0 ]; then
  recorder_exists=true
fi

# 检查 Delivery Channel
channel_count=$(aws configservice describe-delivery-channels --region "$REGION" --query "DeliveryChannels | length(@)" --output text)
channel_exists=false
if [ "$channel_count" -gt 0 ]; then
  channel_exists=true
fi

# 输出 JSON
config_exists=false
if [ "$recorder_exists" = true ] && [ "$channel_exists" = true ]; then
  config_exists=true
fi

echo "{\"recorder_exists\": $recorder_exists, \"delivery_channel_exists\": $channel_exists, \"config_exists\": $config_exists}"