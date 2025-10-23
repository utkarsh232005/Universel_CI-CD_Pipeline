#!/bin/bash
set -e

# Load configuration file
CONFIG_FILE="${CONFIG_FILE:-./config/default.env}"

if [ -f "$CONFIG_FILE" ]; then
  export $(cat "$CONFIG_FILE" | grep -v '^#' | xargs)
  echo "✅ Loaded configuration from: $CONFIG_FILE"
else
  echo "⚠️  Config file not found: $CONFIG_FILE, using defaults"
fi

# Logging function with colors and timestamps
log() {
  echo -e "\033[1;34m[$(date +'%H:%M:%S')]\033[0m $1"
}

log_success() {
  echo -e "\033[1;32m[$(date +'%H:%M:%S')] ✅ $1\033[0m"
}

log_error() {
  echo -e "\033[1;31m[$(date +'%H:%M:%S')] ❌ $1\033[0m"
}

log_warning() {
  echo -e "\033[1;33m[$(date +'%H:%M:%S')] ⚠️  $1\033[0m"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Display environment info
display_env_info() {
  log "Project: $PROJECT_NAME"
  log "Build Command: $BUILD_COMMAND"
  log "Test Command: $TEST_COMMAND"
  log "Deploy Type: $DEPLOY_TYPE"
}
