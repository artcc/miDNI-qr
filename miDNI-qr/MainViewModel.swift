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
    @Published var isScanning = true
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var response: VerifyResponse?
    @Published var rawResponseText: String?

    func handleScan(_ payload: Data) {
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
        guard let url = URL(string: BackendConfig.baseURLString + "/verify") else {
            print("❌ Invalid backend URL")
            isLoading = false
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
            isLoading = false
            errorMessage = "Failed to encode request"
            return
        }

        do {
            let (data, responseObj) = try await URLSession.shared.data(for: request)
            let statusCode = (responseObj as? HTTPURLResponse)?.statusCode ?? -1
            let responseText = String(data: data, encoding: .utf8) ?? "<empty>"
            print("✅ Backend response (status \(statusCode)): \(responseText)")

            self.isLoading = false
            self.rawResponseText = responseText

            do {
                let decoded = try JSONDecoder().decode(VerifyResponse.self, from: data)
                if decoded.valid {
                    self.response = decoded
                } else {
                    self.errorMessage = decoded.reason ?? "Request failed"
                }
            } catch {
                self.errorMessage = "Invalid response"
            }
        } catch {
            self.isLoading = false
            self.errorMessage = "Request failed: \(error.localizedDescription)"
        }
    }
}
