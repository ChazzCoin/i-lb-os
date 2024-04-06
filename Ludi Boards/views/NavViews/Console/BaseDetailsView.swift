//
//  BaseDetailsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 4/1/24.
//

import SwiftUI
import CoreEngine

struct VB: Identifiable {
    let id: UUID
    let viewBuilder: () -> AnyView
    
    init(id: UUID = UUID(), viewBuilder: @escaping () -> AnyView) {
        self.id = id
        self.viewBuilder = viewBuilder
    }
}


struct BaseDetailsView<Header: View, Body: View, Footer: View>: View {
    let navTitle: String
    var headerBuilder: () -> Header
    var bodyBuilder: () -> Body
    var footerBuilder: () -> Footer
    
    var body: some View {
        
        Form {
            
            HStack {
                Spacer().clearSectionBackground()
                HeaderText(navTitle, color: .blue).clearSectionBackground()
                Spacer().clearSectionBackground()
            }
            
            // Header
            headerBuilder()
                .clearSectionBackground()
            
            // Body
            bodyBuilder()
            
            // Footer
            footerBuilder()
                .clearSectionBackground()
            
        }
        .navigationBarTitle(navTitle, displayMode: .inline)
        
        
    }
    
    
}

//#Preview {
//    BaseDetailsView()
//}
