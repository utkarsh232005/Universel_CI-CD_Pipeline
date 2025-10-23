# Contributing to Universal CI/CD Pipeline

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🎯 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Environment details** (OS, Node version, etc.)
- **Configuration file** (sanitized, no secrets!)
- **Workflow logs** (if applicable)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide detailed description** of the suggested enhancement
- **Explain why this would be useful**
- **Provide examples** of how it would work

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Write clear commit messages**
6. **Submit the pull request**

## 🔧 Development Setup

### Prerequisites

- Bash 4.0+
- Git
- Docker (for testing Docker features)
- Node.js 18+ (for testing Node.js projects)

### Local Testing

1. Clone the repository:
```bash
git clone https://github.com/YourUsername/universal-cicd-pipeline.git
cd universal-cicd-pipeline
```

2. Make scripts executable:
```bash
chmod +x pipeline/*.sh
```

3. Test with a sample project:
```bash
export CONFIG_FILE="./config/examples/nodejs-backend.env"
bash pipeline/build.sh
bash pipeline/test.sh
```

## 📝 Coding Standards

### Shell Scripts

- Use `#!/bin/bash` shebang
- Enable strict mode: `set -e`
- Use meaningful variable names
- Add comments for complex logic
- Use the logging functions from `utils.sh`

**Example:**
```bash
#!/bin/bash
set -e

source pipeline/utils.sh

log "Starting deployment process..."
# Your code here
log_success "Deployment completed!"
```

### Configuration Files

- Use uppercase for variable names
- Provide sensible defaults
- Add comments explaining each variable
- Group related variables together

### GitHub Actions Workflows

- Use clear step names with emojis
- Add descriptions to inputs
- Mark optional parameters as `required: false`
- Include error handling

## 🧪 Testing Guidelines

### Before Submitting

- [ ] Test with Node.js projects
- [ ] Test with Python projects
- [ ] Test all deployment types you modified
- [ ] Verify error handling works
- [ ] Check that logs are clear and helpful
- [ ] Ensure no secrets are exposed in logs

### Test Checklist

```bash
# Test build script
./pipeline/build.sh

# Test test script
./pipeline/test.sh

# Test deploy script (use a test environment!)
./pipeline/deploy.sh

# Verify workflow syntax
actionlint .github/workflows/reusable-cicd.yml
```

## 📚 Documentation

When adding new features:

1. Update `README.md` with:
   - New configuration options
   - Usage examples
   - Troubleshooting tips

2. Add example configurations in `config/examples/`

3. Update workflow examples in `examples/workflows/`

4. Add inline comments in scripts

## 🎨 Adding New Deployment Targets

To add a new deployment target (e.g., "firebase"):

1. **Add to `deploy.sh`:**
```bash
"firebase")
  log "🔥 Deploying to Firebase..."
  
  if ! command_exists firebase; then
    log "Installing Firebase CLI..."
    npm i -g firebase-tools
  fi
  
  firebase deploy --token="$FIREBASE_TOKEN"
  log_success "Deployed to Firebase successfully"
  ;;
```

2. **Add configuration variables** to `config/default.env`:
```bash
# Firebase Configuration
FIREBASE_PROJECT_ID=""
FIREBASE_TOKEN=""
```

3. **Update README.md** with:
   - Configuration example
   - Required secrets
   - Usage instructions

4. **Create example config** in `config/examples/firebase-app.env`

5. **Test thoroughly** with a real Firebase project

## 🔐 Security

- **Never commit secrets** or credentials
- **Sanitize logs** to avoid exposing sensitive data
- **Use GitHub Secrets** for all sensitive values
- **Validate inputs** to prevent injection attacks
- **Report security issues** privately via email

## 💬 Communication

- Be respectful and constructive
- Ask questions if unclear
- Provide context in discussions
- Help others when you can

## 📋 Commit Message Guidelines

Use clear, descriptive commit messages:

```
<type>: <subject>

<body>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat: Add Firebase deployment support

- Add Firebase deployment logic to deploy.sh
- Update configuration examples
- Add documentation for Firebase deployment
```

```
fix: Resolve Docker push authentication issue

- Add proper error handling for Docker login
- Improve error messages
```

## 🏆 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- GitHub contributors page

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## ❓ Questions?

Feel free to:
- Open a discussion on GitHub
- Comment on relevant issues
- Reach out to maintainers

Thank you for contributing! 🎉
