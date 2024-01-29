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
    
    @State private var sheetIsShowing = false
    
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(Color.white)
        }
        .frame(width: 60, height: 60)
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
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundColor(Color.white)
        }
        .frame(width: 60, height: 60)
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
