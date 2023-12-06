//
//  ConfirmationPopup.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/5/23.
//

import Foundation
import SwiftUI

struct ConfirmationPopup: View {
    let title: String
    let subtitle: String
    let onAccept: () -> Void
    let onDeny: () -> Void

    var body: some View {
        // Popup content
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Button("Deny") {
                    onDeny()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Accept") {
                    onAccept()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }.padding()
        }
        .frame(width: 400, height: 250)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding() // Adjust the padding for the size of the popup
    }
}
