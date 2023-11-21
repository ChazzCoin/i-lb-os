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
    
    func handleTap() {
        if icon.tool.title == MenuBarProvider.lock.tool.title {
            isLocked = true
        } else {
            isLocked = false
        }
    }

    var body: some View {
        Image(icon.tool.image)
            .resizable()
            .frame(width: 35, height: 35)
            .foregroundColor(isLocked ? .red : Color.white)
            .onTapGesture {
                print("CodiChannel SendTopic: \(icon.tool.title)")
                handleTap()
                CodiChannel.general.send(value: icon.tool.title)
            }
    }
}
