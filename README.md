# 🚀 Universal CI/CD Pipeline Template

A powerful, reusable CI/CD pipeline template for GitHub Actions that works with **any project type** through simple configuration files. Deploy to Docker Hub, AWS, Heroku, Vercel, Netlify, and more with zero code changes to the core pipeline.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Configuration](#-configuration)
- [Deployment Targets](#-deployment-targets)
- [Examples](#-examples)
- [Advanced Usage](#-advanced-usage)
- [Troubleshooting](#-troubleshooting)

## ✨ Features

- **Universal**: Works with Node.js, Python, Next.js, React, Flask, and more
- **Highly Configurable**: Control build, test, and deploy via simple `.env` files
- **Multiple Deploy Targets**: Docker Hub, AWS (EC2/S3), Heroku, Vercel, Netlify
- **Smart Caching**: Automatically caches dependencies for faster builds
- **Docker Support**: Built-in Docker image building and pushing
- **Slack Notifications**: Optional success/failure notifications
- **Matrix Builds**: Support for testing multiple Node.js versions
- **Secrets Management**: Secure handling of API keys and tokens
- **Zero Lock-in**: Use the pipeline without modifying your project structure

## 🚀 Quick Start

### Step 1: Create Your Project Configuration

In your project repository, create a configuration file at `config/myproject.env`:

```bash
# config/myproject.env
PROJECT_NAME="My Awesome App"
BUILD_COMMAND="npm run build"
TEST_COMMAND="npm test"
DOCKER_IMAGE="myusername/my-app"
DEPLOY_TYPE="dockerhub"
```

### Step 2: Add the Workflow

Create `.github/workflows/ci-cd.yml` in your project:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  deploy:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/myproject.env"
    secrets:
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```

### Step 3: Add Required Secrets

Go to your repository's **Settings → Secrets and variables → Actions** and add:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

### Step 4: Push and Deploy! 🎉

```bash
git add .
git commit -m "Add CI/CD pipeline"
git push
```

## ⚙️ Configuration

### Configuration File Options

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `PROJECT_NAME` | Your project name | `"Generic Project"` | `"My E-Commerce Site"` |
| `BUILD_COMMAND` | Command to build your project | `"npm run build"` | `"yarn build"` |
| `TEST_COMMAND` | Command to run tests | `"npm test"` | `"pytest"` |
| `LINT_COMMAND` | Command to run linter | `"none"` | `"npm run lint"` |
| `DOCKER_IMAGE` | Docker image name | `"generic-app"` | `"myorg/app"` |
| `DOCKER_TAG` | Docker image tag | `"latest"` | `"v1.0.0"` |
| `DEPLOY_TYPE` | Where to deploy | `"none"` | See [Deployment Targets](#-deployment-targets) |
| `BUILD_DIR` | Build output directory | `"./build"` | `"./dist"` |
| `INSTALL_DEPENDENCIES` | Auto-install deps | `"true"` | `"false"` |

### Workflow Input Options

```yaml
with:
  config_file: "./config/myproject.env"  # Required
  node_version: "20"                      # Optional, default: 20
  skip_tests: false                       # Optional, default: false
  skip_deploy: false                      # Optional, default: false
```

## 🌍 Deployment Targets

### Docker Hub

```bash
DEPLOY_TYPE="dockerhub"
DOCKER_IMAGE="username/app-name"
DOCKER_TAG="latest"
```

**Required Secrets:**
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

### AWS EC2

```bash
DEPLOY_TYPE="aws_ec2"
AWS_EC2_HOST="ec2-xx-xxx-xxx-xxx.compute-1.amazonaws.com"
AWS_EC2_USER="ubuntu"
DEPLOY_PATH="/var/www/html"
```

**Required Secrets:**
- `AWS_SSH_KEY` (private key content)

### AWS S3 + CloudFront

```bash
DEPLOY_TYPE="aws_s3"
AWS_S3_BUCKET="my-static-site-bucket"
AWS_CLOUDFRONT_ID="E1234567890ABC"  # Optional
BUILD_DIR="./build"
```

**Required Secrets:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Heroku

```bash
DEPLOY_TYPE="heroku"
HEROKU_APP_NAME="my-app-name"
DOCKER_IMAGE="myorg/app"
```

**Required Secrets:**
- `HEROKU_API_KEY`

### Vercel

```bash
DEPLOY_TYPE="vercel"
```

**Required Secrets:**
- `VERCEL_TOKEN`

### Netlify

```bash
DEPLOY_TYPE="netlify"
BUILD_DIR="./dist"
```

**Required Secrets:**
- `NETLIFY_AUTH_TOKEN`
- `NETLIFY_SITE_ID`

### Custom Deployment

```bash
DEPLOY_TYPE="custom"
DEPLOY_COMMAND="./my-deploy-script.sh"
```

## 📚 Examples

### Example 1: Next.js App to Vercel

**config/nextjs.env:**
```bash
PROJECT_NAME="Next.js Portfolio"
BUILD_COMMAND="npm run build"
TEST_COMMAND="npm run lint"
DEPLOY_TYPE="vercel"
```

**Workflow:**
```yaml
jobs:
  deploy:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/nextjs.env"
      node_version: "20"
    secrets:
      VERCEL_TOKEN: ${{ secrets.VERCEL_TOKEN }}
```

### Example 2: Python Flask to AWS S3

**config/flask.env:**
```bash
PROJECT_NAME="Flask API"
BUILD_COMMAND="python -m build"
TEST_COMMAND="pytest tests/"
DEPLOY_TYPE="aws_s3"
AWS_S3_BUCKET="my-flask-api-bucket"
BUILD_DIR="./dist"
```

### Example 3: React App to Netlify

**config/react.env:**
```bash
PROJECT_NAME="React Dashboard"
BUILD_COMMAND="npm run build"
TEST_COMMAND="npm run test:ci"
LINT_COMMAND="npm run lint"
COVERAGE_COMMAND="npm run coverage"
DEPLOY_TYPE="netlify"
BUILD_DIR="./build"
```

### Example 4: Multi-Environment Setup

**Development:**
```yaml
# .github/workflows/dev.yml
on:
  push:
    branches: [ develop ]

jobs:
  dev-deploy:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/dev.env"
```

**Production:**
```yaml
# .github/workflows/prod.yml
on:
  push:
    branches: [ main ]

jobs:
  prod-deploy:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/prod.env"
```

## 🔧 Advanced Usage

### Matrix Builds (Multiple Node Versions)

```yaml
jobs:
  test-matrix:
    strategy:
      matrix:
        node-version: [18, 20, 22]
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/myproject.env"
      node_version: ${{ matrix.node-version }}
      skip_deploy: true  # Only deploy once
```

### Conditional Deployment

```yaml
jobs:
  deploy:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/myproject.env"
      skip_deploy: ${{ github.ref != 'refs/heads/main' }}
```

### Slack Notifications

Add to your workflow secrets:
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

The pipeline will automatically send notifications on success/failure.

### Using the Docker Runner Image

Build the custom runner image:

```bash
cd docker
docker build -f Dockerfile.runner -t cicd-runner:latest .
```

Use in your own workflows for consistent environments.

## 🛠️ Troubleshooting

### Common Issues

**Issue: "Config file not found"**
```
Solution: Ensure the config_file path is relative to your repository root
Example: "./config/myproject.env" not "config/myproject.env"
```

**Issue: "Docker image build failed"**
```
Solution: Make sure you have a Dockerfile in your project root
Set DOCKER_IMAGE to "none" if you don't need Docker builds
```

**Issue: "Dependencies not installing"**
```
Solution: Set INSTALL_DEPENDENCIES="true" in your config
Or add a custom BUILD_COMMAND that includes dependency installation
```

**Issue: "Deployment failed - secrets not found"**
```
Solution: Add required secrets in GitHub Settings → Secrets and variables → Actions
Each deployment type requires specific secrets (see Deployment Targets section)
```

### Debug Mode

Enable detailed logging by adding to your config:

```bash
# In your .env file
set -x  # Enable bash debug mode
```

### Testing Locally

Test your scripts locally:

```bash
# Export your config
export CONFIG_FILE="./config/myproject.env"

# Test build
bash pipeline/build.sh

# Test tests
bash pipeline/test.sh

# Test deploy (be careful!)
bash pipeline/deploy.sh
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the need for truly universal CI/CD pipelines
- Built with GitHub Actions
- Supports the entire modern web development ecosystem

## 📞 Support

- 📫 Create an issue for bug reports or feature requests
- 💬 Start a discussion for questions
- ⭐ Star this repo if you find it useful!

---

**Made with ❤️ for the developer community**
