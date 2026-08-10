# Security Policy

## Reporting a vulnerability

Please do not disclose security vulnerabilities, real Management API addresses, management keys, tokens, account details, or unredacted logs in a public Issue.

Use GitHub's private vulnerability reporting feature when available. If it is unavailable, open an Issue containing only a non-sensitive summary and wait for a maintainer to provide a private contact method.

## Deployment guidance

- Connect only to CLIProxyAPI instances you trust.
- Prefer HTTPS and restrict access to the Management API at the network layer.
- Use a dedicated management key and rotate it if exposure is suspected.
- Review screenshots and logs before sharing them publicly.
- Keep the Android app and CLIProxyAPI server updated.

The application stores the configured Management API address and management key using Android-backed secure storage. It does not ship with a preconfigured private endpoint or credential.

## Official Android signing certificate

CLIProxy v1 releases use the following SHA-256 signing certificate fingerprint:

```text
C4:32:2F:65:9C:61:DF:7F:50:46:10:DD:FE:3B:37:E1:7C:26:1C:55:1A:6D:A3:1E:A0:AB:AC:3C:1D:2E:B9:91
```
