//
//  SolPicker.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/29/24.
//

import Foundation
import SwiftUI

struct SolPicker: View {
    @Binding var selection: String
    var data: [String]
    var title: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        Picker(selection: $selection, label: HeaderText(title)) {
            ForEach(data, id: \.self) { item in
                Text(item)
                    .tag(item)
            }
        }
        .padding(15)
        .background(Color.secondaryBackground) // Change background based on isEditable.
        .accentColor(.white) // Change text color based on isEditable.
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
    }
}
