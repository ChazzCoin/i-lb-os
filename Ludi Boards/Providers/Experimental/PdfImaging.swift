//
//  PdfImaging.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/31/24.
//

import Foundation
import SwiftUI

struct SnapshotViewModifier: ViewModifier {
    @Binding var takeSnapshot: Bool
    let onSnapshot: (UIImage) -> Void

    func body(content: Content) -> some View {
        content
            .background(SnapshotRepresentable(takeSnapshot: $takeSnapshot, onSnapshot: onSnapshot))
    }

    struct SnapshotRepresentable: UIViewRepresentable {
        @Binding var takeSnapshot: Bool
        let onSnapshot: (UIImage) -> Void

        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.isUserInteractionEnabled = false
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            if takeSnapshot {
                if let root = context.coordinator.rootView {
                    let renderer = UIGraphicsImageRenderer(bounds: root.bounds)
                    let image = renderer.image { rendererContext in
                        root.layer.render(in: rendererContext.cgContext)
                    }
                    onSnapshot(image)
                }
                DispatchQueue.main.async {
                    // Reset the flag
                    takeSnapshot = false
                }
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject {
            var parent: SnapshotRepresentable
            weak var rootView: UIView?

            init(_ parent: SnapshotRepresentable) {
                self.parent = parent
            }

            override func awakeFromNib() {
                super.awakeFromNib()
                rootView = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController?.view
            }
        }
    }
}



extension View {
    func snapshot(with boardEngineObject: BoardEngineObject) -> UIImage? {
        let controller = UIHostingController(rootView: self.environmentObject(boardEngineObject))
        // Define the size and the scale of your snapshot
        let size = CGSize(width: 500, height: 500) // Replace with your actual size
        let scale = UIScreen.main.scale
        
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.default())
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
//    func captureAsImage(with boardEngineObject: BoardEngineObject) -> UIImage? {
//        let controller = UIHostingController(rootView: self.environmentObject(boardEngineObject))
//
//        // Set the size and frame of the hosting controller's view
//        let size = UIScreen.main.bounds.size
//        controller.view.frame = CGRect(origin: .zero, size: size)
//        controller.view.sizeToFit()
//
//        // Render the view to a UIImage
//        let renderer = UIGraphicsImageRenderer(size: size)
//        return renderer.image { context in
//            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
//        }
//    }
    
    func captureAsImage(with boardEngineObject: BoardEngineObject, after delay: TimeInterval = 0.1, completion: @escaping (UIImage?) -> Void) {
            let controller = UIHostingController(rootView: self.environmentObject(boardEngineObject))
            
            // Define the size and frame of the hosting controller's view
            controller.view.bounds = UIScreen.main.bounds
            controller.view.sizeToFit()
            
            // Add the hosting controller's view to the current key window
            if let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
                keyWindow.addSubview(controller.view)
                
                // Allow the UI to complete layout
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    let size = controller.view.bounds.size
                    let renderer = UIGraphicsImageRenderer(size: size)
                    let image = renderer.image { _ in
                        controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
                    }
                    
                    // Clean up
                    controller.view.removeFromSuperview()
                    
                    // Return the captured image
                    completion(image)
                }
            } else {
                completion(nil) // Key window not found
            }
        }
}


struct PDFRenderer: UIViewRepresentable {
    let pageSize: CGSize
    let rootView: AnyView

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: pageSize))
        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
}

func createPDF(image: UIImage, pageSize: CGSize) -> Data? {
    let pdfData = NSMutableData()
    UIGraphicsBeginPDFContextToData(pdfData, CGRect(origin: .zero, size: pageSize), nil)
    
    UIGraphicsBeginPDFPage()
    guard let pdfContext = UIGraphicsGetCurrentContext() else { return nil }
    
    let rect = CGRect(origin: .zero, size: pageSize)
    pdfContext.saveGState()
    pdfContext.translateBy(x: 0, y: rect.size.height)
    pdfContext.scaleBy(x: 1.0, y: -1.0)
    pdfContext.draw(image.cgImage!, in: rect)
    pdfContext.restoreGState()
    
    UIGraphicsEndPDFContext()
    
    return pdfData as Data
}

