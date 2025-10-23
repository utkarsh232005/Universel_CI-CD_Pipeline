# Example: How to Use This Pipeline in Your Project

This directory contains example workflow files for different scenarios.

## Basic Usage

**File: `.github/workflows/main.yml`**

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
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

## Multi-Environment Deployment

### Development Workflow

**File: `.github/workflows/dev.yml`**

```yaml
name: Deploy to Development

on:
  push:
    branches: [ develop ]

jobs:
  dev-deploy:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/dev.env"
    secrets:
      VERCEL_TOKEN: ${{ secrets.VERCEL_DEV_TOKEN }}
```

### Production Workflow

**File: `.github/workflows/prod.yml`**

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  release:
    types: [ published ]

jobs:
  prod-deploy:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/prod.env"
    secrets:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## Matrix Testing

**File: `.github/workflows/test-matrix.yml`**

```yaml
name: Test Matrix

on:
  pull_request:
    branches: [ main ]

jobs:
  test:
    strategy:
      matrix:
        node-version: [18, 20, 22]
        os: [ubuntu-latest, macos-latest, windows-latest]
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/test.env"
      node_version: ${{ matrix.node-version }}
      skip_deploy: true
```

## Scheduled Builds

**File: `.github/workflows/nightly.yml`**

```yaml
name: Nightly Build

on:
  schedule:
    - cron: '0 2 * * *'  # Run at 2 AM UTC daily

jobs:
  nightly:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/nightly.env"
      skip_deploy: true
    secrets:
      SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

## Manual Trigger with Inputs

**File: `.github/workflows/manual.yml`**

```yaml
name: Manual Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - dev
          - staging
          - prod
      skip_tests:
        description: 'Skip tests'
        required: false
        type: boolean
        default: false

jobs:
  manual-deploy:
    uses: YourUsername/universal-cicd-pipeline/.github/workflows/reusable-cicd.yml@main
    with:
      config_file: "./config/${{ inputs.environment }}.env"
      skip_tests: ${{ inputs.skip_tests }}
    secrets:
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_TOKEN: ${{ secrets.DOCKERHUB_TOKEN }}
```
