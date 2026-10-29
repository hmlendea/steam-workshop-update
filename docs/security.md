# Implementation Security Model

For support and vulnerability reporting, use the [root security policy](../SECURITY.md). This page analyses code-level trust boundaries rather than reproducing that notice. Consult the [root privacy policy](../PRIVACY.md) for the published data-handling policy and [state inventory](./state-and-persistence.md) for implementation qualifications.

## Trust Boundaries And Exposure

| Boundary | Observed Implementation | Risk Or Limitation |
|---|---|---|
| Workflow author to environment | Script accepts arbitrary caller environment | Secrets need not actually originate in GitHub Secrets |
| Environment to subprocess | Password/seed/code supplied as command arguments; environment inherited | Privileged host/process inspection can expose them |
| Inputs to VDF | Direct heredoc interpolation, followed by full printing | Quotes/newlines can alter VDF; sensitive changenotes/paths become logs |
| Workspace to client | Literal workspace/path concatenation | No traversal containment, existence check, or snapshot |
| Build to external artifacts | Floating base/apt; versioned helper without integrity check | Supply-chain trust and reproducibility gaps |
| Client to retained logs | Inherited output plus terminal log dump | No wrapper-level redaction or sensitivity classifier |
| Concurrent callers to Workshop | Repeated publication without lock | Race/duplicate-update risk and no rollback |

Input strings are not shell-evaluated a second time by the heredoc; do not mislabel VDF injection as demonstrated shell command execution. The accidental `ATTEMPTS` arithmetic variable is a separate unchecked environment influence. The script does not sandbox external binaries or constrain their network access.

## Operational Mitigations

- Use a trusted, isolated runner and narrowly authorized Steam account.
- Supply credentials from protected secrets; never expose them to untrusted contribution workflows.
- Pin a reviewed action commit; separately assess base-image and downloaded-helper provenance.
- Prepare trusted content and validate IDs, paths, and VDF-sensitive characters before publishing.
- Configure caller job timeouts and serialize by Workshop item.
- Restrict access to retained logs; inspect/redact client diagnostics before sharing.
- Rotate credentials after suspected disclosure and review runner/client residual state.

These are recommendations, not controls implemented in this repository. The Dockerfile does not explicitly set a final non-root user. GitHub masking does not guarantee suppression of generated codes or arbitrary external logs.

## Unverified Areas

No dependency audit, image-user inspection, network capture, authentication penetration test, or live upload was conducted. Transport encryption, external binary data handling, actual session files, and Valve retention cannot be established from the wrapper alone. See [open questions](./ambiguities-and-open-questions.md).
