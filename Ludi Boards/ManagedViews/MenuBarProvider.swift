//
//  MenuBarProvider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/11/23.
//

import Foundation
import SwiftUI

protocol IconProvider {
    var title: String { get }
    var image: Image { get } // SwiftUI uses Image directly
    var authLevel: Int { get }
    var color: Color? { get }
}


struct MenuButtonIcon: View {
    var icon: IconProvider // Assuming IconProvider conforms to SwiftUI's View
    var channel: CodiChannel // Define this according to your needs
//    var codiAction: CodiActions // Enum or other type representing actions

    @State private var isLocked = false

    var body: some View {
        VStack {
            icon.image
                .onTapGesture {
                    print("CodiChannel SendTopic: \(icon.title)")
                    // Implement your channel logic here
                }
                .foregroundColor(isLocked ? .red : Color.primary)
            Spacer().frame(height: 16)
        }
        .onAppear {
            // Update isLocked state based on your conditions
        }
    }
}
