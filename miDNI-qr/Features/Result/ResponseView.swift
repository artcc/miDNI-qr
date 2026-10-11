//
//  ResponseView.swift
//  miDNI-qr
//
//  Created by Arturo Carretero Calvo on 7/2/26.
//  Copyright © 2026 Arturo Carretero Calvo. All rights reserved.
//

import SwiftUI

struct ResponseView: View {
    let response: VerifyResponse
    let rawResponseText: String?
    let onScanAgain: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let base64 = response.thumbnailBase64,
                   let image = thumbnailImage(from: base64) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                ForEach(responseFields(from: response), id: \.label) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.label).font(.headline)
                        Text(item.value).font(.body)
                    }
                }

                if let rawResponseText {
                    Text("Raw response")
                        .font(.headline)
                    Text(rawResponseText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button("Scan again") {
                    onScanAgain()
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func thumbnailImage(from base64: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    private func responseFields(from response: VerifyResponse) -> [(label: String, value: String)] {
        var fields: [(String, String)] = []

        if let documentNumber = response.documentNumber { fields.append(("Document number", documentNumber)) }
        if let givenName = response.givenName { fields.append(("Given name", givenName)) }
        if let surnames = response.surnames { fields.append(("Surnames", surnames)) }
        if let birthDate = response.birthDate { fields.append(("Birth date", birthDate)) }
        if let sex = response.sex { fields.append(("Sex", sex)) }
        if let documentExpiry = response.documentExpiry { fields.append(("Document expiry", documentExpiry)) }
        if let nationality = response.nationality { fields.append(("Nationality", nationality)) }
        if let parents = response.parents { fields.append(("Parents", parents)) }
        if let supportNumber = response.supportNumber { fields.append(("Support number", supportNumber)) }
        if let isAdult = response.isAdult { fields.append(("Is adult", isAdult ? "Yes" : "No")) }
        if let dataExpiry = response.dataExpiry { fields.append(("Data expiry", dataExpiry)) }
        if let addressFull = response.addressFull { fields.append(("Address", addressFull)) }
        if let addressLines = response.addressLines { fields.append(("Address lines", addressLines.joined(separator: " | "))) }
        if let placeOfBirthLines = response.placeOfBirthLines { fields.append(("Place of birth", placeOfBirthLines.joined(separator: " | "))) }

        return fields
    }
}
