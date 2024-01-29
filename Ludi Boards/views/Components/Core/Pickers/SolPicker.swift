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
    
    var body: some View {
        Picker(selection: $selection, label: HeaderText(title)) {
            ForEach(data, id: \.self) { item in
                Text(item).tag(item)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}
