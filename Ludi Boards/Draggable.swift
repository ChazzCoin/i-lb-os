//
//  ManagedViewBoardTool.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/12/23.
//

import Foundation
import SwiftUI

struct ManagedViewBoardTool: View {
    let boardId: String
    let viewId: String
    let toolType: String
    
    @State private var color: Color = .black
    @State private var rotation = 0.0
    @State private var tool = "parse toolType into Tool"
    
    @State private var position = CGPoint(x: 100, y: 100)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDragging = false

    var body: some View {
        Image("tool_football")
            .resizable()
            .enableMVT(viewId: viewId)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ManagedViewBoardTool(boardId: "", viewId: "", toolType: "")
    }
}
