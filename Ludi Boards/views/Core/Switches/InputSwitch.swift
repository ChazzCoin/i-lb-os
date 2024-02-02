//
//  InputSwitch.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/21/23.
//

import Foundation
import SwiftUI

struct InputSwitch: View {
    @Binding var isChecked: Bool
    var onCheckedChange: (Bool) -> Void

    var body: some View {
        Toggle(isOn: $isChecked) {
            Text(isChecked ? "On" : "Off")
        }.onChange(of: isChecked, perform: onCheckedChange)
    }
}
