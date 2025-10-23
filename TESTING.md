# Testing Guide

This guide helps you test the Universal CI/CD Pipeline locally before deploying.

## Prerequisites

- Bash 4.0 or higher
- Git
- Node.js (for Node.js projects)
- Python (for Python projects)
- Docker (for Docker-related features)

## Quick Test

### 1. Test Build Script

```bash
export CONFIG_FILE="./config/examples/nodejs-backend.env"
./pipeline/build.sh
```

**Expected Output:**
- ✅ Configuration loaded
- 📦 Dependencies installed (if package.json exists)
- 🔨 Build completed successfully
- ✅ Build stage completed successfully! 🎉

### 2. Test Test Script

```bash
export CONFIG_FILE="./config/examples/nodejs-backend.env"
./pipeline/test.sh
```

**Expected Output:**
- ✅ Configuration loaded
- 🧪 Tests running
- ✅ Tests passed successfully
- ✅ Test stage completed successfully! ✅

### 3. Test Deploy Script (Safely)

```bash
# Use 'none' deployment type for safety
export CONFIG_FILE="./config/default.env"
./pipeline/deploy.sh
```

**Expected Output:**
- ⚠️  No deployment target specified. Skipping deployment.
- ✅ Deployment stage completed! 🎉

## Testing Different Project Types

### Node.js Project

```bash
# Create a test directory
mkdir -p /tmp/test-nodejs-project
cd /tmp/test-nodejs-project

# Initialize npm project
npm init -y

# Add test scripts to package.json
cat > package.json << 'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "build": "echo 'Building...' && mkdir -p dist && echo 'Built!' > dist/output.txt",
    "test": "echo 'Testing...' && exit 0",
    "lint": "echo 'Linting...' && exit 0"
  }
}
EOF

# Create test config
mkdir -p config
cat > config/test.env << 'EOF'
PROJECT_NAME="Test Node.js Project"
BUILD_COMMAND="npm run build"
TEST_COMMAND="npm test"
LINT_COMMAND="npm run lint"
DOCKER_IMAGE="none"
DEPLOY_TYPE="none"
EOF

# Copy pipeline scripts
cp -r /path/to/universal-cicd-pipeline/pipeline .

# Test
export CONFIG_FILE="./config/test.env"
./pipeline/build.sh
./pipeline/test.sh
./pipeline/deploy.sh
```

### Python Project

```bash
# Create a test directory
mkdir -p /tmp/test-python-project
cd /tmp/test-python-project

# Create a simple Python app
cat > app.py << 'EOF'
def hello():
    return "Hello, World!"

if __name__ == "__main__":
    print(hello())
EOF

# Create test file
cat > test_app.py << 'EOF'
from app import hello

def test_hello():
    assert hello() == "Hello, World!"
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
pytest==7.4.0
EOF

# Create test config
mkdir -p config
cat > config/test.env << 'EOF'
PROJECT_NAME="Test Python Project"
BUILD_COMMAND="pip install -r requirements.txt"
TEST_COMMAND="pytest test_app.py -v"
DOCKER_IMAGE="none"
DEPLOY_TYPE="none"
EOF

# Copy pipeline scripts
cp -r /path/to/universal-cicd-pipeline/pipeline .

# Test
export CONFIG_FILE="./config/test.env"
./pipeline/build.sh
./pipeline/test.sh
```

## Testing Docker Features

### Build Docker Image

```bash
# Create a Dockerfile in your test project
cat > Dockerfile << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
CMD ["node", "index.js"]
EOF

# Update config
cat > config/test.env << 'EOF'
PROJECT_NAME="Docker Test"
BUILD_COMMAND="npm run build"
TEST_COMMAND="npm test"
DOCKER_IMAGE="test/my-app"
DOCKER_TAG="latest"
DEPLOY_TYPE="none"
EOF

# Test Docker build
export CONFIG_FILE="./config/test.env"
./pipeline/build.sh

# Verify image was created
docker images | grep test/my-app
```

## Testing Deployment Types

⚠️ **Warning:** Be careful when testing deployments! Use test accounts and environments.

### Test Docker Hub Push (Dry Run)

```bash
# Set up config WITHOUT actually pushing
cat > config/test-docker.env << 'EOF'
PROJECT_NAME="Docker Hub Test"
BUILD_COMMAND="echo 'build'"
TEST_COMMAND="echo 'test'"
DOCKER_IMAGE="username/test-app"
DEPLOY_TYPE="dockerhub"
EOF

# Build image first
docker build -t username/test-app:latest -f- . << 'EOF'
FROM alpine:latest
CMD ["echo", "test"]
EOF

# To actually test pushing, you need to:
# 1. docker login
# 2. Use a real Docker Hub account
# 3. Run: export CONFIG_FILE="./config/test-docker.env" && ./pipeline/deploy.sh
```

### Test AWS S3 Deployment (Dry Run)

```bash
# Install AWS CLI
# brew install awscli  # macOS
# or download from aws.amazon.com

# Configure with test credentials
aws configure

# Create test config
cat > config/test-s3.env << 'EOF'
PROJECT_NAME="S3 Test"
BUILD_COMMAND="mkdir -p build && echo 'test' > build/index.html"
TEST_COMMAND="echo 'test'"
DEPLOY_TYPE="aws_s3"
AWS_S3_BUCKET="my-test-bucket"  # Use a real test bucket!
BUILD_DIR="./build"
EOF

# Test (use a REAL test bucket you own!)
export CONFIG_FILE="./config/test-s3.env"
./pipeline/build.sh
./pipeline/deploy.sh
```

## Testing GitHub Actions Locally

Use [act](https://github.com/nektos/act) to test workflows locally:

```bash
# Install act
brew install act  # macOS
# or use Docker

# Create a test workflow
cat > .github/workflows/test.yml << 'EOF'
name: Test

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test build
        run: |
          export CONFIG_FILE="./config/default.env"
          bash pipeline/build.sh
EOF

# Run with act
act push
```

## Validation Checklist

Before submitting changes:

- [ ] All scripts run without errors
- [ ] Logs are clear and informative
- [ ] Error handling works (try invalid configs)
- [ ] No secrets are exposed in logs
- [ ] Scripts are executable (chmod +x)
- [ ] Documentation is updated
- [ ] Example configs are valid

## Common Issues

### Issue: "Permission denied"

```bash
# Solution: Make scripts executable
chmod +x pipeline/*.sh
```

### Issue: "Config file not found"

```bash
# Solution: Use absolute path or check CONFIG_FILE
export CONFIG_FILE="./config/myproject.env"
# Or use absolute path
export CONFIG_FILE="/full/path/to/config/myproject.env"
```

### Issue: "Command not found: npm/docker/aws"

```bash
# Solution: Install required tools
# For npm: Install Node.js
# For docker: Install Docker Desktop
# For aws: Install AWS CLI
```

### Issue: "Docker build failed"

```bash
# Solution: Ensure Dockerfile exists
ls -la Dockerfile

# Or set DOCKER_IMAGE="none" if not using Docker
```

## Debug Mode

Enable verbose logging:

```bash
# Add to your script
set -x  # Enable debug mode
set -e  # Exit on error
set -u  # Error on undefined variables

# Run script
bash -x ./pipeline/build.sh
```

## Clean Up

After testing:

```bash
# Remove test Docker images
docker rmi test/my-app:latest

# Remove test files
rm -rf /tmp/test-*-project

# Unset environment variables
unset CONFIG_FILE
```

## Automated Testing

Create a test script:

```bash
#!/bin/bash
# test-all.sh

set -e

echo "Running all tests..."

# Test 1: Default config
export CONFIG_FILE="./config/default.env"
./pipeline/build.sh
./pipeline/test.sh
./pipeline/deploy.sh

# Test 2: Node.js example
export CONFIG_FILE="./config/examples/nodejs-backend.env"
./pipeline/build.sh

# Test 3: Python example
export CONFIG_FILE="./config/examples/python-flask.env"
./pipeline/build.sh

echo "✅ All tests passed!"
```

## CI Testing

The pipeline itself can be tested in GitHub Actions:

```yaml
name: Test Pipeline

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Test build script
        run: |
          export CONFIG_FILE="./config/default.env"
          bash pipeline/build.sh
      
      - name: Test test script
        run: |
          export CONFIG_FILE="./config/default.env"
          bash pipeline/test.sh
```

Happy testing! 🧪
