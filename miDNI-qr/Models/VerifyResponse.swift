//
//  VerifyResponse.swift
//  miDNI-qr
//
//  Created by Arturo Carretero Calvo on 7/2/26.
//  Copyright © 2026 Arturo Carretero Calvo. All rights reserved.
//

import Foundation

struct VerifyResponse: Decodable {
    let valid: Bool
    let reason: String?
    let documentNumber: String?
    let givenName: String?
    let surnames: String?
    let birthDate: String?
    let sex: String?
    let documentExpiry: String?
    let nationality: String?
    let parents: String?
    let supportNumber: String?
    let isAdult: Bool?
    let dataExpiry: String?
    let addressFull: String?
    let addressLines: [String]?
    let placeOfBirthLines: [String]?
    let thumbnailBase64: String?
    let rawFields: [String: AnyDecodable]?
}

struct AnyDecodable: Decodable {}
