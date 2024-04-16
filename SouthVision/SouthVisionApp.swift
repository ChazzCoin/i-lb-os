//
//  SouthVisionApp.swift
//  SouthVision
//
//  Created by Charles Romeo on 4/15/24.
//

import SwiftUI


@main
struct SouthVisionApp: App {
    
//    @State private var style: ImmersionStyle = .mixed
    
    var body: some Scene {
        WindowGroup {
            SpaceCanvasEngine(
                global: { _ in
//                    ContentView()
//                    ZStack{
//                        ContentView()
//                    }
//                    .frame(width: 500, height: 500)
//                    .background(.red)
                },
                canvas: { gps in
                    ContentView().position(gps.center())
                })
        }
//        .immersionStyle(selection: $style, in: .mixed)

        
//        ImmersiveSpace(id: "ImmersiveSpace") {
//            ImmersiveView()
////            Text("HELLLOOOOOOO")
//        }.immersionStyle(selection: $style, in: .mixed)
    }
}
