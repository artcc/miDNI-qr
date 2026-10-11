# Contributing

Thanks for your interest in contributing to miDNI-qr, a SwiftUI proof of concept for scanning Spain's DNIe data through miDNI QR codes.

## Scope

- This POC aims to stay minimal.
- Focus on bug fixes, clarity, and documentation.
- Large feature additions should be discussed in an issue first.
- Preserve the existing scanning flow and backend contract unless a change is explicitly agreed upon and coordinated with [miDNI-backend](https://github.com/artcc/miDNI-backend).

## Development setup

1. Check the [requirements in the README](README.md#requirements).
2. Set up [miDNI-backend](https://github.com/artcc/miDNI-backend) and make it reachable from your iPhone.
3. Set the API base URL and bearer token in [`miDNI-qr/Configuration/BackendConfig.swift`](miDNI-qr/Configuration/BackendConfig.swift). Both are required for the end-to-end flow; follow the [configuration instructions](README.md#2-configure-the-ios-app).
4. Open `miDNI-qr.xcodeproj` in Xcode and select your development team in **Signing & Capabilities**, if needed.
5. Run on a physical iPhone and grant camera access. Scanning uses the **front camera**.

## Coding guidelines

- Keep SwiftUI views simple and focused.
- Follow the existing folder structure: features under `Features/`, API models under `Models/`, and shared views under `Shared/Views/`.
- Prefer `@MainActor` for UI state mutations.
- Avoid adding third-party dependencies unless justified.
- Use explicit error messages that are user-friendly.
- Preserve the error-corrected QR codewords sent in `payloadBytes`, the `POST /verify` endpoint, and bearer authentication unless the backend contract is intentionally updated.

## Testing

There are no automated tests yet. For changes affecting app behavior, smoke test the relevant scenarios on a physical iPhone with the backend configured:

- Scan a valid miDNI QR code using the front camera.
- Confirm that one verification request is sent per scan and the loading state is shown.
- Check that a successful response displays the expected document fields and photo, when present.
- Confirm that a QR rejected by the backend displays an error.
- Check the error state when the backend is unreachable.
- Tap **Scan again** after both a result and an error, and confirm that scanning resumes.
- For preview layout changes, check that the camera preview fits its view after resizing.

The [included QR specification](documentation/MiDNI-FormatoQR_v107_sc_PN.pdf) contains sample QR codes for valid, expired, and modified data scenarios. Its valid examples use a test signing certificate; configure the backend accordingly when using them.

Building for the simulator does not validate camera scanning. In the PR, describe which scenarios you checked, the device and iOS version used, and anything left untested. Documentation-only changes do not require a device smoke test.

## Documentation

- Update [README](README.md) and [CHANGELOG](CHANGELOG.md) for user-visible changes.
- Use concise, action-oriented bullet points.

## Submitting changes

1. Create a branch from `main`.
2. Make focused commits with clear messages.
3. Open a PR describing the change and how it was tested.
