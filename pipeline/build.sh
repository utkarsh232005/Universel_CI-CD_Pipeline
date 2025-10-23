#!/bin/bash
set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log "🏗️  Starting Build Stage"
display_env_info

# Check if dependencies need to be installed
if [ -f "package.json" ] && [ "$INSTALL_DEPENDENCIES" != "false" ]; then
  log "📦 Installing dependencies..."
  if [ -f "package-lock.json" ]; then
    npm ci
  elif [ -f "yarn.lock" ]; then
    yarn install --frozen-lockfile
  else
    npm install
  fi
  log_success "Dependencies installed"
fi

# Check if requirements.txt exists (Python projects)
if [ -f "requirements.txt" ] && [ "$INSTALL_DEPENDENCIES" != "false" ]; then
  log "🐍 Installing Python dependencies..."
  pip install -r requirements.txt
  log_success "Python dependencies installed"
fi

# Execute build command
if [ -n "$BUILD_COMMAND" ] && [ "$BUILD_COMMAND" != "none" ]; then
  log "🔨 Building project: $PROJECT_NAME"
  eval "$BUILD_COMMAND"
  log_success "Build completed successfully"
else
  log_warning "No build command specified, skipping build"
fi

# Optional: Build Docker image if specified
if [ -n "$DOCKER_IMAGE" ] && [ "$DOCKER_IMAGE" != "none" ] && [ -f "Dockerfile" ]; then
  log "🐋 Building Docker image: $DOCKER_IMAGE"
  DOCKER_TAG="${DOCKER_TAG:-latest}"
  docker build -t "$DOCKER_IMAGE:$DOCKER_TAG" .
  
  # Tag with commit SHA if available
  if [ -n "$GITHUB_SHA" ]; then
    SHORT_SHA=$(echo $GITHUB_SHA | cut -c1-7)
    docker tag "$DOCKER_IMAGE:$DOCKER_TAG" "$DOCKER_IMAGE:$SHORT_SHA"
    log_success "Docker image built and tagged: $DOCKER_IMAGE:$DOCKER_TAG and $DOCKER_IMAGE:$SHORT_SHA"
  else
    log_success "Docker image built: $DOCKER_IMAGE:$DOCKER_TAG"
  fi
fi

log_success "Build stage completed successfully! 🎉"
