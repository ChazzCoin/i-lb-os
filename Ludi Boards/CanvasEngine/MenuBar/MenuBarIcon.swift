//
//  MenuBarIcon.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/17/23.
//

import Foundation
import SwiftUI

struct MenuButtonIcon: View {
    var icon: IconProvider // Assuming IconProvider conforms to SwiftUI's View

    @State private var isLocked = false

    var body: some View {
        VStack {
            
            Image(icon.tool.image)
                .resizable()
                .zIndex(15.0)
                .frame(width: 35, height: 35)
                .onTapGesture {
                    print("CodiChannel SendTopic: \(icon.tool.title)")
                    CodiChannel.general.send(value: icon.tool.title)
                }
                .foregroundColor(isLocked ? .red : Color.primary)
            Spacer().frame(height: 8)
        }
        .onAppear {
            // Update isLocked state based on your conditions
        }
    }
}
