//
//  RotationSlider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

//struct RotationSlider: View {
//    @State private var currentRotation: Float = 0
//    let viewId: String
//    let codiRealm = realm()
//
//    var body: some View {
//        VStack {
//            Text("Rotation: \(currentRotation)")
//            Slider(
//                value: $currentRotation,
//                in: 0...360,
//                step: 1,
//                onEditingChanged: { editing in
//                    if !editing {
//                        // Equivalent of onValueChangeFinished
//                        sendRotationUpdate()
//                    }
//                }
//            )
//        }
//        .frame(height: 75)
//        .onAppear {
//            loadInitialValues()
//        }
//    }
//
//    private func loadInitialValues() {
//        // Assuming ManagedView and findById method exist and work similarly to your Compose code
//        guard let mv = codiRealm.findByField(ManagedView.self, field: "id", value: viewId) else { return }
//        currentRotation = Float(mv.rotation)
//        print("Loaded Current rotation: \(currentRotation)")
//    }
//
//    private func sendRotationUpdate() {
//        // Equivalent of sending data through CodiChannel
////        CodiChannel.TOOL_ATTRIBUTES.send(ViewAttributesPayload(
////            viewId: viewId,
////            rotation: currentRotation
////        ))
//    }
//}
