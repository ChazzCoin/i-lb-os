//
//  MVSettingsView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/28/23.
//

import Foundation
import SwiftUI
import Combine

enum ToolLevels: Int {
    case BASIC = 0
    case LINE = 10
    case SMART = 20
    case PREMIUM = 30
}

struct SettingsView: View {
    
    var onDelete: () -> Void
    
    let realmInstance = realm()
    @State var viewSize: CGFloat = 50
    @State var viewRotation: Double = 0
    @State var viewColor: Color = .black
    
    @State var toolType: Int = ToolLevels.BASIC.rawValue
    
    @State var viewId: String = ""
    
    let colors: [Color] = [Color.red, Color.blue]
    private let circleSize: CGFloat = 40
    private let spacing: CGFloat = 10

    @State private var isLoading = false
    @State private var showCompletion = false
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        LoadingForm(isLoading: $isLoading, showCompletion: $showCompletion) { runLoading in
            
            Text("MV Tool Settings: \(viewId)")
            
            // Settings
            Section(header: Text("Size: \(Int(viewSize))")) {
                
                Slider(value: $viewSize, 
                   in: 10...175,
                   onEditingChanged: { editing in
                        if !editing {
                            let va = ViewAtts(viewId: viewId, size: viewSize)
                            CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                        }
                    }
                ).padding()

                

                
            }
            .padding(.horizontal)

            Section(header: Text("Rotation: \(Int(viewRotation))")) {
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
                
            }.padding(.horizontal)
            
            Section(header: Text("Color")) {
            
                ColorListPicker() { color in
                    print("Color Picker Tapper")
                    viewColor = color
                    let va = ViewAtts(viewId: viewId, color: viewColor)
                    CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                }
                
            }.padding(.horizontal)
            
            solButton(title: "Delete Tool", action: {
                // Delete View
                print("Trash")
                let va = ViewAtts(viewId: viewId, isDeleted: true)
                CodiChannel.TOOL_ATTRIBUTES.send(value: va)
                CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "mv_settings", stateAction: "close", viewId: viewId))
                viewId = ""
            })
        }
        .background(Color.clear)
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            Button(action: {
                print("Minimize")
                CodiChannel.MENU_WINDOW_CONTROLLER.send(value: WindowController(windowId: "mv_settings", stateAction: "close", viewId: viewId))
            }) {
                Image(systemName: "minus")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
        })
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
