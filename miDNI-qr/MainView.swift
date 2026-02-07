//
//  MainView.swift
//  miDNI-qr
//
//  Created by Arturo Carretero Calvo on 4/2/26.
//  Copyright © 2026 Arturo Carretero Calvo. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isScanning {
                ScannerView { payload in
                    viewModel.handleScan(payload)
                }
                .frame(maxWidth: .infinity, maxHeight: 360)
                .background(.black.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else if viewModel.isLoading {
                LoadingView()
            } else if let response = viewModel.response {
                ResponseView(response: response, rawResponseText: viewModel.rawResponseText) {
                    viewModel.resetForScan()
                }
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(message: errorMessage) {
                    viewModel.resetForScan()
                }
            }
        }
        .padding()
    }
}
