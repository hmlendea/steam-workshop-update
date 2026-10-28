# Contributing to steam-workshop-update

This document covers the guidelines and processes for contributing to this project, including how to report issues, suggest enhancements, submit code changes, and follow project standards.

## 📑 Table of Contents

- [How to Contribute](#-how-to-contribute)
  - [Reporting Issues](#reporting-issues)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Code Contributions](#code-contributions)
    - [Prerequisites](#prerequisites)
    - [Development Setup](#development-setup)
    - [Making Changes](#making-changes)
    - [Pull Request Guidelines](#pull-request-guidelines)
  - [Code Style](#code-style)
  - [Testing](#testing)
  - [Documentation](#documentation)
- [License](#-license)
- [Getting Assistance](#-getting-assistance)

## 🤝 How to Contribute

### Reporting Issues

- Search existing issues first.
- Use the issue templates if available.
- Provide clear reproduction steps.
- Include environment details.

### Suggesting Enhancements

- Check the roadmap and existing discussions.
- Explain the use case and expected behaviour.
- Consider implementation complexity.

### Code Contributions

#### Prerequisites

- Docker

#### Development Setup

```bash
# Clone the repository
git clone https://github.com/hmlendea/steam-workshop-update.git
cd steam-workshop-update

# Install dependencies
docker build -t steam-workshop-update .
```

#### Making Changes

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes.
4. Commit with clear and descriptive messages.
5. Push to your fork.
6. Open a Pull Request.

#### Pull Request Guidelines

- Target the `master` branch.
- Keep PRs focused and atomic.
- Revise documentation if applicable.
- Ensure the CI checks pass.

### Code Style

Follow the project's coding standards:
- Shell scripts use `set -euo pipefail`, `[[ ]]` for conditionals, and POSIX-standard commands
- Run `shellcheck` before committing if available.

### Testing

No automated tests exist. Validate changes by running the Docker image locally:

```bash
docker run --rm steam-workshop-update
```

### Documentation

- Revise relevant docs for changes.
- Follow the documentation style guide.
- Preview changes locally if possible.

## 📄 License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0.

## ❓ Getting Assistance

- Open an issue on GitHub
- Check existing discussions and documentation first.