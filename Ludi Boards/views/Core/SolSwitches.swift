//
//  SolSwitches.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/14/24.
//

import Foundation
import SwiftUI
import CoreEngine

struct SwitchOnOff: View {
    var title: String
    @Binding var status: Bool
    @State var isEnabled: Bool
    
    init(title: String, status: Binding<Bool>, isEnabled: Bool = true) {
        self.title = title
        self._status = status
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Button("ON") {
                if isEnabled { status = true }
            }
            .buttonStyle(.bordered)
            .tint(status == true ? .green : .gray)
            
            Button("OFF") {
                if isEnabled { status = false }
            }
            .buttonStyle(.bordered)
            .tint(status == false ? .red : .gray)
        }
    }
}


struct SwitchShowHide: View {
    @Binding var status: Bool
    
    var body: some View {
        HStack {
            Button("Show") {
                status = true
            }
            .buttonStyle(.bordered)
            .tint(status == true ? .green : .gray)
            
            Button("Hide") {
                status = false
            }
            .buttonStyle(.bordered)
            .tint(status == false ? .red : .gray)
        }
    }
}
