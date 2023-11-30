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
    @Environment(\.colorScheme) var colorScheme
    @State private var isLocked = false
    @State private var lifeColor = Color.black
    
    func setColorScheme() { lifeColor = foregroundColorForScheme(colorScheme) }
    
    func handleTap() {
        if icon.tool.title == MenuBarProvider.lock.tool.title {
            isLocked = !isLocked
            lifeColor = isLocked ? Color.red : foregroundColorForScheme(colorScheme)
        }
    }

    var body: some View {
        Image(systemName: icon.tool.image)
            .resizable()
            .frame(width: 35, height: 35)
            .foregroundColor(lifeColor)
            .onTapAnimation {
                print("CodiChannel SendTopic: \(icon.tool.title)")
                handleTap()
                CodiChannel.general.send(value: icon.tool.title)
            }.onAppear() {
                setColorScheme()
            }
    }
}
