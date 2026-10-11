//
//  QRScannerController.swift
//  miDNI-qr
//
//  Created by Arturo Carretero Calvo on 7/2/26.
//  Copyright © 2026 Arturo Carretero Calvo. All rights reserved.
//

import AVFoundation
import CoreImage
import Foundation

final class QRScannerController: NSObject {
    private var didDeliverPayload = false
    private var isConfigured = false

    private let sessionQueue = DispatchQueue(label: "qr.session.queue")
    private let metadataQueue = DispatchQueue(label: "qr.metadata.queue")
    private let stateQueue = DispatchQueue(label: "qr.state.queue")
    private let metadataOutput = AVCaptureMetadataOutput()

    var onPayload: ((Data) -> Void)?

    let session = AVCaptureSession()

    override init() {
        super.init()
        setupSessionObserver()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        print("🎥 Starting scanner...")
        resetDeliveryState()

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("🎥 Authorization status: \(status.rawValue)")

        switch status {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            requestCameraAccess()
        case .denied, .restricted:
            print("❌ Camera permission denied or restricted")
        @unknown default:
            print("❌ Unknown permission status")
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                print("🎥 Stopping capture session...")
                self.session.stopRunning()
            }
        }
    }

    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            print("🎥 Permission granted: \(granted)")
            guard granted else {
                print("❌ Camera permission denied")
                return
            }
            self?.configureAndStart()
        }
    }

    private func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if !self.isConfigured {
                self.isConfigured = self.configureSession()
            }

            guard self.isConfigured else { return }

            if !self.session.isRunning {
                print("🎥 Starting capture session...")
                self.session.startRunning()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.session.isRunning {
                        print("✅ Session started successfully")
                    } else {
                        print("❌ ERROR: Session failed to start")
                    }
                }
            }
        }
    }

    private func configureSession() -> Bool {
        print("🎥 Configuring session...")

        guard !session.isRunning else {
            print("⚠️ Session already running")
            return false
        }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        // Use high resolution preset for better QR detection.
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
            print("🎥 Preset set: high")
        } else if session.canSetSessionPreset(.medium) {
            session.sessionPreset = .medium
            print("🎥 Preset set: medium")
        }

        // Configure camera input.
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("❌ Front camera not found")
            return false
        }

        print("🎥 Camera found: \(device.localizedName)")

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ Failed to create camera input")
            return false
        }

        guard session.canAddInput(input) else {
            print("❌ Cannot add input")
            return false
        }

        session.addInput(input)
        print("🎥 Input added")

        // Configure metadata output for QR.
        guard session.canAddOutput(metadataOutput) else {
            print("❌ Cannot add metadata output")
            session.removeInput(input)
            return false
        }

        session.addOutput(metadataOutput)
        print("🎥 Metadata output added")

        // Check available types and configure only QR.
        let availableTypes = metadataOutput.availableMetadataObjectTypes
        print("🎥 Available types: \(availableTypes.count)")

        guard availableTypes.contains(.qr) else {
            print("❌ QR not available on this device")
            session.removeOutput(metadataOutput)
            session.removeInput(input)
            return false
        }

        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
        metadataOutput.metadataObjectTypes = [.qr]
        print("🎥 Configured to detect: QR")
        print("🎥 Configuration completed ✅")
        return true
    }

    private func setupSessionObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionWasInterrupted),
            name: AVCaptureSession.wasInterruptedNotification,
            object: session
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: AVCaptureSession.interruptionEndedNotification,
            object: session
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionRuntimeError),
            name: AVCaptureSession.runtimeErrorNotification,
            object: session
        )
    }

    @objc private func sessionWasInterrupted(notification: NSNotification) {
        print("⚠️ Session interrupted")
    }

    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        print("✅ Interruption ended")
        // Auto-restart the session.
        sessionQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }

    @objc private func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print("❌ Runtime error: \(error.localizedDescription) (code: \(error.code.rawValue))")

        if error.code == .mediaServicesWereReset {
            sessionQueue.async { [weak self] in
                self?.session.startRunning()
            }
        }
    }

    private func resetDeliveryState() {
        stateQueue.sync { didDeliverPayload = false }
    }

    private func extractBinaryPayload(from qrCode: AVMetadataMachineReadableCodeObject) -> Data? {
        // Send the error-corrected QR codewords unchanged, as expected by the backend.
        if let descriptor = qrCode.descriptor as? CIQRCodeDescriptor {
            let rawPayload = descriptor.errorCorrectedPayload
            print("📦 errorCorrectedPayload: \(rawPayload.count) bytes")
            return rawPayload
        }

        return nil
    }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        // Bail out early if we've already delivered a payload.
        let alreadyDelivered = stateQueue.sync { didDeliverPayload }

        guard !alreadyDelivered else { return }

        for metadataObject in metadataObjects {
            guard let qrCode = metadataObject as? AVMetadataMachineReadableCodeObject,
                  qrCode.type == .qr else {
                continue
            }

            print("✅ QR detected!")

            // Mark as delivered before processing.
            var shouldNotify = false
            stateQueue.sync {
                if !didDeliverPayload {
                    didDeliverPayload = true
                    shouldNotify = true
                }
            }

            guard shouldNotify else { return }

            // Extract binary payload.
            guard let payload = extractBinaryPayload(from: qrCode) else {
                // Reset flag if extraction failed.
                stateQueue.sync { didDeliverPayload = false }
                continue
            }

            print("📤 Delivering payload of \(payload.count) bytes")

            // Stop before delivering to avoid more callbacks.
            stop()

            // Deliver payload.
            DispatchQueue.main.async { [weak self] in
                self?.onPayload?(payload)
            }

            return
        }
    }
}
