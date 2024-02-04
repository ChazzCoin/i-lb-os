//
//  SolIconButton.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/21/24.
//

import SwiftUI

struct SolIconButton: View {
    var systemName: String
    var onTap: () -> Void
    
    @State var fontColor: Color = .white
    @State var width = 60.0
    @State var height = 60.0
    @State private var sheetIsShowing = false
    
    init(systemName: String, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.onTap = onTap
    }
    
    init(systemName: String, width: Double, height: Double, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.width = width
        self.height = height
        self.onTap = onTap
    }
    
    init(systemName: String, width: Double, height: Double, fontColor: Color, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.fontColor = fontColor
        self.width = width
        self.height = height
        self.onTap = onTap
    }
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: width/2, height: height/2)
                .foregroundColor(fontColor)
        }
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color.primaryBackground)
                .shadow(radius: 5)
        )
        .onTapAnimation {
           onTap()
        }
    }
}


struct SolIconConfirmButton: View {
    var systemName: String
    let title: String
    let message: String
    var onTap: () -> Void
    var isEnabled: Bool = true
    @State private var sheetIsShowing = false
    
    @State var width = 60.0
    @State var height = 60.0
    
    init(systemName: String, title: String, message: String, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.title = title
        self.message = message
        self.onTap = onTap
    }
    
    init(systemName: String, title: String, message: String, width: Double, height: Double, onTap: @escaping () -> Void) {
        self.systemName = systemName
        self.title = title
        self.message = message
        self.width = width
        self.height = height
        self.onTap = onTap
    }
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: width/2, height: height/2)
                .foregroundColor(Color.white)
        }
        .frame(width: width, height: height)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color.primaryBackground)
                .shadow(radius: 5)
        )
        .solEnabled(isEnabled: isEnabled)
        .onTapAnimation(enabled: isEnabled) {
            if isEnabled {
                sheetIsShowing = true
            }
        }
        .alert(title, isPresented: $sheetIsShowing) {
            Button("Cancel", role: .cancel) {
                sheetIsShowing = false
            }
            Button("OK", role: .none) {
                sheetIsShowing = false
                onTap()
            }
        } message: {
            Text(message)
        }
    }
}

#Preview {
    SolIconButton(systemName: MenuBarProvider.trash.tool.image) {
        
    }
}
