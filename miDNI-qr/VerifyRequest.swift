//
//  VerifyRequest.swift
//  miDNI-qr
//
//  Created by Arturo Carretero Calvo on 7/2/26.
//  Copyright © 2026 Arturo Carretero Calvo. All rights reserved.
//

import Foundation

struct VerifyRequest: Encodable {
    let payloadBytes: [UInt8]
}
