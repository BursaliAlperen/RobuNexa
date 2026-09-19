# Website login -> EXE (device authentication, RFC 8628 + PKCK)

## Flow
1. EXE: generates random `code_verifier`, sends only `SHA256(verifierifier)`.