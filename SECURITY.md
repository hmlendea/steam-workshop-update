# Security Policy

This document outlines the security practices for the `steam-workshop-update` GitHub Action, including how to report vulnerabilities, supported versions, and the disclosure policy.

## 📑 Table of Contents

- [Supported Versions](#supported-versions)
- [Reporting a Vulnerability](#reporting-a-vulnerability)
- [Scope](#scope)
- [Disclosure Policy](#disclosure-policy)

## 🛡️ Supported Versions

Use this table to indicate which project versions currently receive security maintenance.

| Version | Distribution Channel | Supported |
|---------|--------------------|-----------|
| Latest version | GitHub Actions | ✅ |
| Preceding versions | Any distribution channel | ❌ |

## 🚨 Reporting a Vulnerability

Please do not disclose suspected vulnerabilities publicly before maintainers have had an opportunity to validate and remediate them.

To report a vulnerability:
- [GitHub Security Advisories](https://github.com/hmlendea/steam-workshop-update/security/advisories)
- Contact the maintainers directly via [GitHub Issues](https://github.com/hmlendea/steam-workshop-update/issues).

## 📌 Scope

The original maintainers are not responsible for changes, modifications, or security issues introduced by downstream forks.

The following report categories are in scope for this repository:
- Vulnerabilities in the Docker image or entrypoint script logic.
- Authentication or credential handling flaws.
- Data exposure or improper access controls.
- Misconfigurations in the default setup.
- Vulnerabilities in dependencies used by the action.

The following categories are out of scope unless explicitly stated to the contrary:
- Vulnerabilities in the Steam Workshop API or Steam client.
- Vulnerabilities in third-party tools or libraries used by the action (e.g., `steamcmd`).
- Vulnerabilities in the GitHub Actions platform itself.
- Vulnerabilities in user-provided content or inputs.

## 📢 Disclosure Policy

This project follows coordinated disclosure:
1. Vulnerabilities are investigated privately.
2. A remediation plan is prepared and validated.
3. Public disclosure is published after a fix, mitigation, or agreed risk decision is available.
4. Credit is attributed in accordance with reporter preference and project policy.

## 🙏 Recognition

We appreciate responsible disclosure. Reporters who desire public attribution may be acknowledged in release notes or advisories.