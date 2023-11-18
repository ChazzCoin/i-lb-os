//
//  ManagedViewToolBar.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI

struct ManagedViewTaskbar: View {
    let title: String
    var onMinimize: (() -> Void)?
    var onFullScreen: (() -> Void)?
    var onSizeDown: (() -> Void)?
    var onWindowToggle: (() -> Void)?

    var body: some View {
        HStack {
//            Spacer()
            
            // Center Title
            Text(title)
                .fontWeight(.bold)

//            Spacer()

            // Window Toggle Button
            Button(action: { onWindowToggle?() }) {
                Image(systemName: "minimize") 
                    .resizable()
                    .frame(width: 50, height: 50)
            }

            // Full Screen Button
            Button(action: { onFullScreen?() }) {
                Image(systemName: "minimize") 
                    .resizable()
                    .frame(width: 50, height: 50)
            }

            // Size Down Button
            Button(action: { onSizeDown?() }) {
                Image(systemName: "minimize") 
                    .resizable()
                    .frame(width: 50, height: 50)
            }

            // Minimize Button
            Button(action: { onMinimize?() }) {
                Image(systemName: "minimize")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .padding(8)
        .background(Color.blue)
        .cornerRadius(10.0)
    }
}

struct ManagedViewTaskbar_Previews: PreviewProvider {
    static var previews: some View {
        ManagedViewTaskbar(title: "Window Title")
    }
}
