//
//  ARKitView.swift
//  Wrlds
//
//  Created by Charles Romeo on 4/15/24.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

extension ARViewModel {
    func setupUpdateTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { [weak self] _ in
//            NotificationCenter.default.post(name: ARKit.Notification., object: nil)
        }
    }
}

class ARViewModelOriginal: ObservableObject {
    var arView: ARView?
    @Published var buttonPosition: CGPoint? = nil
    
    // Function to handle a tap on the AR view and create an anchor
    func placeAnchor(at point: CGPoint) {
        guard let arView = arView else { return }
        
        // Perform a ray-cast to find a physical surface
        let results = arView.raycast(from: point, allowing: .existingPlaneGeometry, alignment: .any)
        
        if let firstResult = results.first {
            // Create an anchor at the hit point
            let anchor = AnchorEntity(world: firstResult.worldTransform)
            arView.scene.addAnchor(anchor)
            
            updateButtonPosition(using: anchor)
        }
    }
    
    func updateButtonPosition(using anchorEntity: AnchorEntity) {
        let position = anchorEntity.position(relativeTo: nil)
        let projectedPosition = arView?.project(position) ?? .zero
        
        DispatchQueue.main.async {
            self.buttonPosition = CGPoint(x: CGFloat(projectedPosition.x), y: CGFloat(projectedPosition.y))
        }
    }

//    func updateButtonPosition(using anchorEntity: AnchorEntity) {
//        guard let arView = arView else { return }
//
//        // Get the 3D position of the anchor entity
//        let anchorPosition = anchorEntity.position(relativeTo: nil)
//        let position = SIMD3<Float>(anchorPosition.x, anchorPosition.y, anchorPosition.z)
//
//        // Project the 3D position to 2D screen coordinates
//        let projectedPosition = arView.project(position)
//
//        DispatchQueue.main.async {
//            self.buttonPosition = CGPoint(x: CGFloat(projectedPosition?.x ?? .zero), y: CGFloat(projectedPosition?.y ?? .zero))
//        }
//    }
}
class ARViewModel: ObservableObject {
    var arView: ARView?
    @Published var buttonPosition: CGPoint? = nil

    func placeAnchor(at point: CGPoint) {
        guard let arView = self.arView else { return }
        
        let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            let anchor = AnchorEntity(world: firstResult.worldTransform)
            arView.scene.addAnchor(anchor)
            
            updateButtonPosition(using: anchor)
        }
    }

    func updateButtonPosition(using anchorEntity: AnchorEntity) {
        let position = anchorEntity.position(relativeTo: nil)
        let projectedPosition = arView?.project(position) ?? .zero
        
        DispatchQueue.main.async {
            self.buttonPosition = CGPoint(x: CGFloat(projectedPosition.x), y: CGFloat(projectedPosition.y))
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewModel.arView = arView
        
        // Set up a tap gesture recognizer
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator,
                                                    action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapRecognizer)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, arView: viewModel.arView)
    }

    class Coordinator: NSObject {
        var viewModel: ARViewModel
        var arView: ARView?
        
        init(viewModel: ARViewModel, arView: ARView?) {
            self.viewModel = viewModel
            self.arView = arView
        }
        
        @objc func handleTap(recognizer: UITapGestureRecognizer) {
            let location = recognizer.location(in: arView)
            viewModel.placeAnchor(at: location)
        }
    }
}
struct ARViewContainerOriginal: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        viewModel.arView = arView // Assign the ARView to the viewModel

        // Example: Adding an anchor
        let anchor = AnchorEntity(world: [0,0,-1]) // Adjust this based on your AR setup
        arView.scene.addAnchor(anchor)
        
        // Example to periodically update the button's position
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            viewModel.updateButtonPosition(using: anchor)
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

//struct ARViewContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        ARViewContainer()
//    }
//}
