//
//  ScannerView.swift
//  miDNI-qr
//
//  Created by Arturo Carretero Calvo on 4/2/26.
//  Copyright © 2026 Arturo Carretero Calvo. All rights reserved.
//

import SwiftUI

struct ScannerView: View {
    @State private var scanner = QRScannerController()

    let onPayload: (Data) -> Void

    var body: some View {
        CameraPreview(session: scanner.session)
            .onAppear {
                scanner.onPayload = onPayload
                scanner.start()
            }
            .onDisappear {
                scanner.stop()
            }
    }
}
