//
//  MVSettingsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/28/23.
//

import Foundation
import SwiftUI
import Combine

struct SettingsView: View {
    
    var onDelete: () -> Void
    
    let realmInstance = realm()
    @State var viewSize: CGFloat = 50
    @State var viewRotation: Double = 0
    @State var viewColor: Color = .black
    
    @State var viewId: String = ""
    
    let colors: [Color] = [Color.red, Color.blue]
    private let circleSize: CGFloat = 40
    private let spacing: CGFloat = 10

    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            
            Text("MV Tool Settings: \(viewId)")
            
            // Top row of icons
            HStack {
                Button(action: { print("onTrashDelete") }) {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
                // Add more icons here as needed
                Spacer()
            }

            // Settings
            Group {
                
                Text("Size: \(Int(viewSize))")
                Slider(value: $viewSize, 
                   in: 10...175,
                   onEditingChanged: { editing in
                        if !editing {
                            let va = ViewAtts(viewId: viewId, size: viewSize)
                            CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                        }
                    }
                ).padding()

                Text("Rotation: \(Int(viewRotation))")
                Slider(
                    value: $viewRotation,
                    in: 0...360,
                    step: 1,
                    onEditingChanged: { editing in
                        if !editing {
                            let va = ViewAtts(viewId: viewId, rotation: viewRotation)
                            CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                        }
                    }
                ).padding()

                Text("Color")
                BoardColorPicker { colorIn in
                    viewColor = colorIn
                    let va = ViewAtts(viewId: viewId, color: viewColor)
                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
//        .onTapGesture {
//            print("tapper")
//        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .onAppear() {
            CodiChannel.TOOL_ATTRIBUTES.receive(on: RunLoop.main) { vId in
                let temp = vId as! ViewAtts
                viewId = temp.viewId
                if let ts = temp.size { viewSize = ts }
                if let tr = temp.rotation { viewRotation = tr }
                if let tc = temp.color { viewColor = tc }
            }.store(in: &cancellables)
        }
        .onDisappear() {
            let va = ViewAtts(viewId: viewId, stateAction: "close")
            CodiChannel.TOOL_ATTRIBUTES.send(value: va)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(onDelete: {})
    }
}
