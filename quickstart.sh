#!/bin/bash

# Quick Start Script for Universal CI/CD Pipeline
# This script helps you set up the pipeline in your project

set -e

echo "🚀 Universal CI/CD Pipeline - Quick Start"
echo "=========================================="
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Error: Not in a git repository!"
  echo "Please run this script from your project's root directory."
  exit 1
fi

# Get project information
echo "Let's set up your CI/CD pipeline!"
echo ""
read -p "Project name: " PROJECT_NAME
read -p "Build command (e.g., npm run build): " BUILD_COMMAND
read -p "Test command (e.g., npm test): " TEST_COMMAND
read -p "Docker image name (or 'none'): " DOCKER_IMAGE
echo ""
echo "Deployment options:"
echo "1) dockerhub"
echo "2) aws_ec2"
echo "3) aws_s3"
echo "4) vercel"
echo "5) netlify"
echo "6) heroku"
echo "7) none"
read -p "Select deployment type (1-7): " DEPLOY_CHOICE

case $DEPLOY_CHOICE in
  1) DEPLOY_TYPE="dockerhub" ;;
  2) DEPLOY_TYPE="aws_ec2" ;;
  3) DEPLOY_TYPE="aws_s3" ;;
  4) DEPLOY_TYPE="vercel" ;;
  5) DEPLOY_TYPE="netlify" ;;
  6) DEPLOY_TYPE="heroku" ;;
  7) DEPLOY_TYPE="none" ;;
  *) DEPLOY_TYPE="none" ;;
esac

echo ""
echo "📝 Creating configuration file..."

# Create config directory if it doesn't exist
mkdir -p config

# Create configuration file
cat > config/myproject.env << EOF
# Project Configuration
PROJECT_NAME="$PROJECT_NAME"

# Build Configuration
BUILD_COMMAND="$BUILD_COMMAND"
INSTALL_DEPENDENCIES="true"
BUILD_DIR="./build"

# Test Configuration
TEST_COMMAND="$TEST_COMMAND"
LINT_COMMAND="npm run lint"
COVERAGE_COMMAND="none"

# Docker Configuration
DOCKER_IMAGE="$DOCKER_IMAGE"
DOCKER_TAG="latest"

# Deployment Configuration
DEPLOY_TYPE="$DEPLOY_TYPE"
EOF

echo "✅ Configuration file created: config/myproject.env"
echo ""

# Create .github/workflows directory
echo "📝 Creating GitHub Actions workflow..."
mkdir -p .github/workflows

# Get GitHub username
read -p "Enter the GitHub username/org where universal-cicd-pipeline is located: " GH_USERNAME

# Create workflow file
cat > .github/workflows/ci-cd.yml << EOF
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  deploy:
    uses: $GH_USERNAME/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/myproject.env"
    secrets:
      DOCKERHUB_USERNAME: \${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: \${{ secrets.DOCKERHUB_TOKEN }}
      AWS_ACCESS_KEY_ID: \${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
      VERCEL_TOKEN: \${{ secrets.VERCEL_TOKEN }}
      NETLIFY_AUTH_TOKEN: \${{ secrets.NETLIFY_AUTH_TOKEN }}
      NETLIFY_SITE_ID: \${{ secrets.NETLIFY_SITE_ID }}
EOF

echo "✅ Workflow file created: .github/workflows/ci-cd.yml"
echo ""

echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and edit config/myproject.env if needed"
echo "2. Add required secrets to your GitHub repository:"
echo "   Settings → Secrets and variables → Actions"
echo ""
case $DEPLOY_TYPE in
  "dockerhub")
    echo "   Required secrets:"
    echo "   - DOCKERHUB_USERNAME"
    echo "   - DOCKERHUB_TOKEN"
    ;;
  "aws_ec2"|"aws_s3")
    echo "   Required secrets:"
    echo "   - AWS_ACCESS_KEY_ID"
    echo "   - AWS_SECRET_ACCESS_KEY"
    ;;
  "vercel")
    echo "   Required secrets:"
    echo "   - VERCEL_TOKEN"
    ;;
  "netlify")
    echo "   Required secrets:"
    echo "   - NETLIFY_AUTH_TOKEN"
    echo "   - NETLIFY_SITE_ID"
    ;;
esac
echo ""
echo "3. Commit and push your changes:"
echo "   git add ."
echo "   git commit -m 'Add CI/CD pipeline'"
echo "   git push"
echo ""
echo "📚 For more information, visit:"
echo "   https://github.com/$GH_USERNAME/universal-cicd-pipeline"
