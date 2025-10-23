#!/bin/bash

# Setup Verification Script
# Run this to verify your Universal CI/CD Pipeline installation

set -e

echo "🔍 Universal CI/CD Pipeline - Setup Verification"
echo "=================================================="
echo ""

ERRORS=0
WARNINGS=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} Found: $1"
    else
        echo -e "${RED}✗${NC} Missing: $1"
        ((ERRORS++))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Directory: $1"
    else
        echo -e "${RED}✗${NC} Missing directory: $1"
        ((ERRORS++))
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} Executable: $1"
    else
        echo -e "${YELLOW}⚠${NC}  Not executable: $1 (run: chmod +x $1)"
        ((WARNINGS++))
    fi
}

echo "📁 Checking Directory Structure..."
echo ""

check_dir ".github"
check_dir ".github/workflows"
check_dir ".github/ISSUE_TEMPLATE"
check_dir "pipeline"
check_dir "config"
check_dir "config/examples"
check_dir "docker"
check_dir "examples"
check_dir "examples/workflows"

echo ""
echo "📄 Checking Core Files..."
echo ""

# GitHub workflow
check_file ".github/workflows/reusable-cicd.yml"
check_file ".github/PULL_REQUEST_TEMPLATE.md"
check_file ".github/ISSUE_TEMPLATE/bug_report.md"
check_file ".github/ISSUE_TEMPLATE/feature_request.md"

# Pipeline scripts
check_file "pipeline/utils.sh"
check_file "pipeline/build.sh"
check_file "pipeline/test.sh"
check_file "pipeline/deploy.sh"

# Configuration files
check_file "config/default.env"
check_file "config/sample.env"
check_file "config/examples/nodejs-backend.env"
check_file "config/examples/nextjs-app.env"
check_file "config/examples/python-flask.env"
check_file "config/examples/react-app.env"
check_file "config/examples/vue-app.env"

# Docker
check_file "docker/Dockerfile.runner"

# Documentation
check_file "README.md"
check_file "CONTRIBUTING.md"
check_file "TESTING.md"
check_file "SECURITY.md"
check_file "CHANGELOG.md"
check_file "LICENSE"
check_file ".gitignore"

# Scripts
check_file "quickstart.sh"

echo ""
echo "🔐 Checking File Permissions..."
echo ""

check_executable "pipeline/utils.sh"
check_executable "pipeline/build.sh"
check_executable "pipeline/test.sh"
check_executable "pipeline/deploy.sh"
check_executable "quickstart.sh"

echo ""
echo "🧪 Testing Pipeline Scripts..."
echo ""

# Test utils.sh sourcing
if source pipeline/utils.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} utils.sh can be sourced"
else
    echo -e "${RED}✗${NC} utils.sh has syntax errors"
    ((ERRORS++))
fi

# Test build.sh syntax
if bash -n pipeline/build.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} build.sh syntax OK"
else
    echo -e "${RED}✗${NC} build.sh has syntax errors"
    ((ERRORS++))
fi

# Test test.sh syntax
if bash -n pipeline/test.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} test.sh syntax OK"
else
    echo -e "${RED}✗${NC} test.sh has syntax errors"
    ((ERRORS++))
fi

# Test deploy.sh syntax
if bash -n pipeline/deploy.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} deploy.sh syntax OK"
else
    echo -e "${RED}✗${NC} deploy.sh has syntax errors"
    ((ERRORS++))
fi

echo ""
echo "📊 Checking Configuration Files..."
echo ""

# Check default.env
if grep -q "PROJECT_NAME" config/default.env; then
    echo -e "${GREEN}✓${NC} default.env contains required variables"
else
    echo -e "${RED}✗${NC} default.env missing required variables"
    ((ERRORS++))
fi

echo ""
echo "🐳 Checking Docker..."
echo ""

if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC} Docker installed"
else
    echo -e "${YELLOW}⚠${NC}  Docker not installed (optional, but recommended)"
    ((WARNINGS++))
fi

echo ""
echo "🔧 Checking Development Tools..."
echo ""

# Check for git
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓${NC} Git installed ($(git --version))"
else
    echo -e "${RED}✗${NC} Git not installed"
    ((ERRORS++))
fi

# Check for bash version
BASH_VERSION_NUM=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
if (( $(echo "$BASH_VERSION_NUM >= 4.0" | bc -l) )); then
    echo -e "${GREEN}✓${NC} Bash version OK ($BASH_VERSION_NUM)"
else
    echo -e "${YELLOW}⚠${NC}  Bash version $BASH_VERSION_NUM (recommend 4.0+)"
    ((WARNINGS++))
fi

# Check for Node.js (optional)
if command -v node &> /dev/null; then
    echo -e "${GREEN}✓${NC} Node.js installed ($(node --version))"
else
    echo -e "${YELLOW}⚠${NC}  Node.js not installed (optional, for Node.js projects)"
    ((WARNINGS++))
fi

# Check for Python (optional)
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✓${NC} Python installed ($(python3 --version))"
else
    echo -e "${YELLOW}⚠${NC}  Python not installed (optional, for Python projects)"
    ((WARNINGS++))
fi

echo ""
echo "=================================================="
echo "📋 Verification Summary"
echo "=================================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ Perfect! Your setup is complete and ready to use!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Push this repository to GitHub"
    echo "2. Use it in your projects with:"
    echo "   uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main"
    echo ""
    echo "Or run ./quickstart.sh in your project to set up automatically!"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Setup complete with $WARNINGS warning(s)${NC}"
    echo ""
    echo "Your setup is functional but consider addressing the warnings above."
else
    echo -e "${RED}❌ Setup incomplete: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    echo ""
    echo "Please fix the errors above before using the pipeline."
    exit 1
fi

echo ""
echo "📚 Documentation:"
echo "  - README.md       - Main documentation"
echo "  - TESTING.md      - Testing guide"
echo "  - CONTRIBUTING.md - How to contribute"
echo "  - SECURITY.md     - Security policy"
echo ""
echo "💡 Need help? Check the documentation or open an issue!"
