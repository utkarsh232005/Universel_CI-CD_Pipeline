#!/bin/bash
set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

log "🚀 Starting Deployment Stage"
display_env_info

# Determine deployment type
DEPLOY_TYPE="${DEPLOY_TYPE:-none}"

case "$DEPLOY_TYPE" in
  "dockerhub")
    log "🐋 Deploying to Docker Hub..."
    
    if [ -z "$DOCKER_IMAGE" ]; then
      log_error "DOCKER_IMAGE not specified for Docker Hub deployment"
      exit 1
    fi
    
    DOCKER_TAG="${DOCKER_TAG:-latest}"
    log "Pushing image: $DOCKER_IMAGE:$DOCKER_TAG"
    docker push "$DOCKER_IMAGE:$DOCKER_TAG"
    
    # Push commit SHA tag if available
    if [ -n "$GITHUB_SHA" ]; then
      SHORT_SHA=$(echo $GITHUB_SHA | cut -c1-7)
      docker push "$DOCKER_IMAGE:$SHORT_SHA"
      log_success "Pushed tags: $DOCKER_TAG and $SHORT_SHA"
    else
      log_success "Pushed tag: $DOCKER_TAG"
    fi
    ;;

  "aws_ec2")
    log "☁️  Deploying to AWS EC2..."
    
    if [ -z "$AWS_EC2_HOST" ] || [ -z "$AWS_EC2_USER" ]; then
      log_error "AWS_EC2_HOST and AWS_EC2_USER must be specified"
      exit 1
    fi
    
    # Setup SSH key if provided
    if [ -n "$AWS_SSH_KEY" ]; then
      mkdir -p ~/.ssh
      echo "$AWS_SSH_KEY" > ~/.ssh/deploy_key
      chmod 600 ~/.ssh/deploy_key
      SSH_KEY_PARAM="-i ~/.ssh/deploy_key"
    fi
    
    # Deploy to EC2
    log "Deploying to $AWS_EC2_USER@$AWS_EC2_HOST:$DEPLOY_PATH"
    
    if [ -n "$DEPLOY_COMMAND" ]; then
      eval "$DEPLOY_COMMAND"
    else
      rsync -avz $SSH_KEY_PARAM -e "ssh -o StrictHostKeyChecking=no" \
        --exclude 'node_modules' \
        --exclude '.git' \
        ./ "$AWS_EC2_USER@$AWS_EC2_HOST:$DEPLOY_PATH"
    fi
    
    log_success "Deployed to EC2 successfully"
    ;;

  "aws_s3")
    log "☁️  Deploying to AWS S3..."
    
    if [ -z "$AWS_S3_BUCKET" ]; then
      log_error "AWS_S3_BUCKET must be specified"
      exit 1
    fi
    
    if ! command_exists aws; then
      log_error "AWS CLI not installed"
      exit 1
    fi
    
    BUILD_DIR="${BUILD_DIR:-./build}"
    log "Syncing $BUILD_DIR to s3://$AWS_S3_BUCKET"
    aws s3 sync "$BUILD_DIR" "s3://$AWS_S3_BUCKET" --delete
    
    # Invalidate CloudFront if distribution ID is provided
    if [ -n "$AWS_CLOUDFRONT_ID" ]; then
      log "Invalidating CloudFront distribution..."
      aws cloudfront create-invalidation \
        --distribution-id "$AWS_CLOUDFRONT_ID" \
        --paths "/*"
    fi
    
    log_success "Deployed to S3 successfully"
    ;;

  "heroku")
    log "🌐 Deploying to Heroku..."
    
    if [ -z "$HEROKU_APP_NAME" ]; then
      log_error "HEROKU_APP_NAME must be specified"
      exit 1
    fi
    
    if ! command_exists heroku; then
      log_error "Heroku CLI not installed"
      exit 1
    fi
    
    if [ -n "$HEROKU_API_KEY" ]; then
      echo "$HEROKU_API_KEY" | docker login --username=_ --password-stdin registry.heroku.com
      docker tag "$DOCKER_IMAGE:latest" "registry.heroku.com/$HEROKU_APP_NAME/web"
      docker push "registry.heroku.com/$HEROKU_APP_NAME/web"
      heroku container:release web --app "$HEROKU_APP_NAME"
    fi
    
    log_success "Deployed to Heroku successfully"
    ;;

  "vercel")
    log "▲ Deploying to Vercel..."
    
    if ! command_exists vercel; then
      log "Installing Vercel CLI..."
      npm i -g vercel
    fi
    
    if [ -n "$VERCEL_TOKEN" ]; then
      vercel --prod --token="$VERCEL_TOKEN" --yes
    else
      log_error "VERCEL_TOKEN must be specified"
      exit 1
    fi
    
    log_success "Deployed to Vercel successfully"
    ;;

  "netlify")
    log "🌊 Deploying to Netlify..."
    
    if ! command_exists netlify; then
      log "Installing Netlify CLI..."
      npm i -g netlify-cli
    fi
    
    BUILD_DIR="${BUILD_DIR:-./build}"
    
    if [ -n "$NETLIFY_AUTH_TOKEN" ] && [ -n "$NETLIFY_SITE_ID" ]; then
      netlify deploy --prod --dir="$BUILD_DIR" \
        --auth="$NETLIFY_AUTH_TOKEN" \
        --site="$NETLIFY_SITE_ID"
    else
      log_error "NETLIFY_AUTH_TOKEN and NETLIFY_SITE_ID must be specified"
      exit 1
    fi
    
    log_success "Deployed to Netlify successfully"
    ;;

  "custom")
    log "🔧 Running custom deployment..."
    
    if [ -n "$DEPLOY_COMMAND" ]; then
      eval "$DEPLOY_COMMAND"
      log_success "Custom deployment completed"
    else
      log_error "DEPLOY_COMMAND must be specified for custom deployment"
      exit 1
    fi
    ;;

  "none")
    log_warning "No deployment target specified. Skipping deployment."
    ;;

  *)
    log_error "Unknown deployment type: $DEPLOY_TYPE"
    log "Supported types: dockerhub, aws_ec2, aws_s3, heroku, vercel, netlify, custom, none"
    exit 1
    ;;
esac

log_success "Deployment stage completed! 🎉"
