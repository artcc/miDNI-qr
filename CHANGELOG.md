# Changelog

All notable changes to this project will be documented in this file.

## [0.0.2] - 2026-10-11
- Organized Swift files into app, configuration, models, features, and shared views folders.
- Fixed camera configuration success tracking and cleanup after partial failures.
- Updated the camera preview to resize automatically with its view.
- Restricted view model state mutations, prevented duplicate scan submissions, and centralized loading state cleanup.
- Clarified the QR payload comment while preserving the existing backend contract.
- Changed the project license from Apache-2.0 to MIT and updated the README.

## [0.0.1] - 2026-02-07
- Initial SwiftUI demo with camera-based QR scanning.
- Extracts binary QR payloads and posts to `/verify`.
- Renders decoded document fields and optional thumbnail.
- Includes loading, error, and retry states.
