//
//  MainViewModel.swift
//  miDNI-qr
//
//  Created by Arturo Carretero Calvo on 4/2/26.
//  Copyright © 2026 Arturo Carretero Calvo. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class MainViewModel: ObservableObject {
    @Published private(set) var isScanning = true
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var response: VerifyResponse?
    @Published private(set) var rawResponseText: String?

    func handleScan(_ payload: Data) {
        guard isScanning else { return }

        isScanning = false
        isLoading = true
        errorMessage = nil
        response = nil
        rawResponseText = nil

        let bytes = [UInt8](payload)
        Task { await sendPayload(bytes) }
    }

    func resetForScan() {
        isScanning = true
        isLoading = false
        errorMessage = nil
        response = nil
        rawResponseText = nil
    }

    private func sendPayload(_ payloadBytes: [UInt8]) async {
        defer { isLoading = false }

        guard let url = URL(string: BackendConfig.baseURLString + "/verify") else {
            print("❌ Invalid backend URL")
            errorMessage = "Invalid backend URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(BackendConfig.bearerToken)", forHTTPHeaderField: "Authorization")

        let body = VerifyRequest(payloadBytes: payloadBytes)
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            print("❌ Failed to encode request: \(error)")
            errorMessage = "Failed to encode request"
            return
        }

        do {
            let (data, responseObj) = try await URLSession.shared.data(for: request)
            let statusCode = (responseObj as? HTTPURLResponse)?.statusCode ?? -1
            let responseText = String(data: data, encoding: .utf8) ?? "<empty>"
            print("✅ Backend response (status \(statusCode)): \(responseText)")

            rawResponseText = responseText

            do {
                let decoded = try JSONDecoder().decode(VerifyResponse.self, from: data)
                if decoded.valid {
                    response = decoded
                } else {
                    errorMessage = decoded.reason ?? "Request failed"
                }
            } catch {
                errorMessage = "Invalid response"
            }
        } catch {
            errorMessage = "Request failed: \(error.localizedDescription)"
        }
    }
}
