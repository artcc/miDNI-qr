# Contributing

Thanks for your interest in contributing to this demo.

## Scope
- This repo is a small SwiftUI demo and aims to stay minimal.
- Focus on bug fixes, clarity, and documentation.
- Large feature additions should be discussed in an issue first.

## Development setup
1. Open `miDNI-qr.xcodeproj` in Xcode.
2. Run on a physical iPhone (camera required).
3. Configure backend settings in `BackendConfig.swift` if needed.

## Coding guidelines
- Keep SwiftUI views simple and focused.
- Prefer `@MainActor` for UI state mutations.
- Avoid adding third-party dependencies unless justified.
- Use explicit error messages that are user-friendly.

## Testing
- There are no automated tests yet.
- Please smoke test on a real device after changes:
	- QR scan flow
	- Backend request and response rendering
	- Error and retry states

## Documentation
- Update README and CHANGELOG for user-visible changes.
- Use concise, action-oriented bullet points.

## Submitting changes
1. Create a branch from `main`.
2. Make focused commits with clear messages.
3. Open a PR describing the change and how it was tested.