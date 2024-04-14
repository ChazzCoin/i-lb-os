//
//  SolSwitches.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/14/24.
//

import Foundation
import SwiftUI


public struct SwitchOnOff: View {
    public var title: String
    @Binding public var status: Bool
    @State public var isEnabled: Bool
    
    public init(title: String, status: Binding<Bool>, isEnabled: Bool = true) {
        self.title = title
        self._status = status
        self.isEnabled = isEnabled
    }
    
    public var body: some View {
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


public struct SwitchShowHide: View {
    @Binding public var status: Bool
    
    public init(status: Binding<Bool>) {
        self._status = status
    }
    
    public var body: some View {
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
