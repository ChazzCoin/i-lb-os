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

public struct SwitchFullHalfHide: View {
    @State public var status: String = "hide"
    
    public var onChange: (String) -> Void
    
    public init(onChange: @escaping (String) -> Void) {
//        self._status = status
        self.onChange = onChange
    }
    
    public var body: some View {
        HStack {
            Button("Full") {
                status = "full"
                onChange("full")
            }
            .buttonStyle(.bordered)
            .tint(status == "full" ? .green : .gray)
            
            Button("Half") {
                status = "half"
                onChange("half")
            }
            .buttonStyle(.bordered)
            .tint(status == "half" ? .orange : .gray)
            
            Button("Hide") {
                status = "hide"
                onChange("hide")
            }
            .buttonStyle(.bordered)
            .tint(status == "hide" ? .red : .gray)
        }
    }
}
