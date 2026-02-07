//
//  ErrorStateView.swift
//  miDNI-qr
//
//  Created by Arturo Carretero Calvo on 7/2/26.
//  Copyright © 2026 Arturo Carretero Calvo. All rights reserved.
//

import SwiftUI

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Error")
                .font(.title2)
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)

            Button("Scan again") {
                onRetry()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
