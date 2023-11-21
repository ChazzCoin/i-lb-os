//
//  SizeSlider.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import SwiftUI

struct WidthHeightSlider: View {
    @State private var currentValue: Float = 0
    let viewId: String
    // Assuming CodiRealmCore and CodiChannel are available in your SwiftUI project
    let codiRealm = realm()

    var body: some View {
        VStack {
            Text("Size: \(currentValue)")
            Slider(
                value: $currentValue,
                in: 75...150,
                step: 1,
                onEditingChanged: { editing in
                    if !editing {
                        // Equivalent of onValueChangeFinished
                        updateSize()
                    }
                }
            )
        }
        .frame(height: 50)
        .onAppear {
            loadInitialValues()
        }
    }

    private func loadInitialValues() {
        // Assuming ManagedView and findById method exist and work similarly to your Compose code
        guard let mv = codiRealm.findByField(ManagedView.self, field: "id", value: viewId) else { return }
        let width = Float(mv.width)
        let height = Float(mv.height)
        if currentValue != width {
            currentValue = height
            print("Loaded Current Width/Height: \(currentValue)")
        }
    }

    private func updateSize() {
        let width = currentValue
        let height = currentValue
        // Equivalent of sending data through CodiChannel
        // Assuming ViewAttributesPayload and TOOL_ATTRIBUTES are available in your SwiftUI project
//        CodiChannel.TOOL_ATTRIBUTES.send(ViewAttributesPayload(
//            viewId: viewId,
//            width: width,
//            height: height
//        ))
    }
}

// Dummy structs and classes to compile the example
struct ViewAttributesPayload {
    var viewId: String
    var width: Float
    var height: Float
}



