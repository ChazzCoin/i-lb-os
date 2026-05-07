////
////  SpatialEngine.swift
////  Ludi Boards
////
////  Created by Charles Romeo on 1/26/26.
////
//
////
////  SpatialEngineView.swift
////
////  Fully camera-based 3D spatial engine (no canvas transforms)
////
//
//import SwiftUI
//import Combine
//
//// MARK: - Math Types
//
//typealias Vec3 = SIMD3<Double>
//
//// MARK: - Projection Output
//
//struct ProjectedPoint {
//    let position: CGPoint
//    let scale: CGFloat
//}
//
//// MARK: - Spatial Node
//
//struct SpatialNode: Identifiable {
//    let id: String
//    var position: Vec3
//    var rotation: Vec3
//    let view: AnyView
//}
//
//// MARK: - Camera Model
//
//@MainActor
//final class Camera3D: ObservableObject {
//    @Published var position: Vec3 = .init(0, 0, -1500)
//    @Published var rotation: Vec3 = .init(0, 0, 0) // pitch, yaw, roll
//    let focalLength: Double = 1000
//}
//
//// MARK: - Projection
//
//func project3D(
//    world: Vec3,
//    camera: Camera3D
//) -> ProjectedPoint {
//
//    var p = world - camera.position
//
//    // Pitch (X)
//    let cx = cos(camera.rotation.x)
//    let sx = sin(camera.rotation.x)
//    p = Vec3(
//        p.x,
//        p.y * cx - p.z * sx,
//        p.y * sx + p.z * cx
//    )
//
//    // Yaw (Y)
//    let cy = cos(camera.rotation.y)
//    let sy = sin(camera.rotation.y)
//    p = Vec3(
//        p.x * cy + p.z * sy,
//        p.y,
//        -p.x * sy + p.z * cy
//    )
//
//    // Roll (Z)
//    let cz = cos(camera.rotation.z)
//    let sz = sin(camera.rotation.z)
//    p = Vec3(
//        p.x * cz - p.y * sz,
//        p.x * sz + p.y * cz,
//        p.z
//    )
//
//    let scale = camera.focalLength / max(1, camera.focalLength - p.z)
//
//    return ProjectedPoint(
//        position: CGPoint(
//            x: CGFloat(p.x * scale),
//            y: CGFloat(p.y * scale)
//        ),
//        scale: CGFloat(scale)
//    )
//}
//
//// MARK: - Spatial Engine View
//
//struct SpatialEngineView: View {
//
//    @StateObject private var camera = Camera3D()
//
//    // Example nodes (replace with Realm-backed data)
//    @State private var nodes: [SpatialNode] = [
//        SpatialNode(
//            id: "A",
//            position: Vec3(-300, 0, 0),
//            rotation: CGFloat(.zero),
//            view: AnyView(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color.blue)
//                    .frame(width: 200, height: 120)
//            )
//        ),
//        SpatialNode(
//            id: "B",
//            position: Vec3(300, 0, -400),
//            rotation: CGFloat(.zero),
//            view: AnyView(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color.green)
//                    .frame(width: 200, height: 120)
//            )
//        )
//    ]
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//
//            ZStack {
//                ForEach($nodes) { $node in
//                    let projected = project3D(
//                        world: node.position,
//                        camera: camera
//                    )
//
//                    node.view
//                        .scaleEffect(projected.scale)
//                        .rotation3DEffect(
//                            .radians(node.rotation.x),
//                            axis: (x: 1, y: 0, z: 0),
//                            perspective: 0.8
//                        )
//                        .rotation3DEffect(
//                            .radians(node.rotation.y),
//                            axis: (x: 0, y: 1, z: 0),
//                            perspective: 0.8
//                        )
//                        .rotation3DEffect(
//                            .radians(node.rotation.z),
//                            axis: (x: 0, y: 0, z: 1)
//                        )
//                        .position(projected.position)
//                }
//            }
//        }
//        .gesture(panGesture.simultaneously(with: zoomGesture).simultaneously(with: orbitGesture))
//    }
//
//    // MARK: - Gestures
//
//    private var panGesture: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                let depthScale: Double =
//                camera.focalLength / max(1.0, abs(Double($camera.position.z)))
//
//                camera.position.x -= Double(value.translation.width) / depthScale
//                camera.position.y -= Double(value.translation.height) / depthScale
//            }
//    }
//
//    private var zoomGesture: some Gesture {
//        MagnificationGesture()
//            .onChanged { value in
//                let delta = Double(value - 1.0)
//                camera.position.z += delta * 600.0
//            }
//    }
//
//    private var orbitGesture: some Gesture {
//        RotationGesture()
//            .onChanged { angle in
//                camera.rotation.y += angle.radians * 0.6
//            }
//    }
//
//}
