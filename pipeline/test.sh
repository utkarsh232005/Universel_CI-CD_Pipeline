#!/bin/bash
set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log "🧪 Starting Test Stage"
display_env_info

# Execute test command
if [ -n "$TEST_COMMAND" ] && [ "$TEST_COMMAND" != "none" ]; then
  log "Running tests for: $PROJECT_NAME"
  eval "$TEST_COMMAND"
  log_success "Tests passed successfully"
else
  log_warning "No test command specified, skipping tests"
fi

# Optional: Run linting if specified
if [ -n "$LINT_COMMAND" ] && [ "$LINT_COMMAND" != "none" ]; then
  log "🔍 Running linter..."
  eval "$LINT_COMMAND"
  log_success "Linting passed"
fi

# Optional: Run code coverage if specified
if [ -n "$COVERAGE_COMMAND" ] && [ "$COVERAGE_COMMAND" != "none" ]; then
  log "📊 Running code coverage..."
  eval "$COVERAGE_COMMAND"
  log_success "Code coverage completed"
fi

log_success "Test stage completed successfully! ✅"
