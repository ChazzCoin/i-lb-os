//
//  RedesignBoardCanvas.swift
//  Ludi Boards — tactical board redesign (RD-2 / TASK-013)
//
//  Hosts the LIVE engine board (`BoardEngine` → `MVEngine.Display`) inside the
//  redesign chrome. The engine tool-render subtree depends only on `BEO`
//  (no nav/window EnvironmentObjects), so this replicates CanvasEngine's board
//  layer — the 20000×20000 canvas coordinate space, the canvas transform, and
//  the pan/zoom gestures — with nothing else. This is what makes the redesign
//  board show real `ManagedView` tools instead of the scaffold's sample tokens.
//

import SwiftUI
import CoreEngine

struct RedesignBoardCanvas: View {
    @EnvironmentObject var BEO: BoardEngineObject

    @GestureState private var dragOffset = CGSize.zero
    @State private var lastOffset = CGPoint.zero

    var body: some View {
        GlobalPositioningZStack(coordinateSpace: CoreNameSpace.canvas.name,
                                width: 20000, height: 20000) { _ in
            BoardEngine()
                .environmentObject(self.BEO)
        }
        .offset(x: self.BEO.canvasOffset.x, y: self.BEO.canvasOffset.y)
        .scaleEffect(self.BEO.canvasScale)
        .rotationEffect(Angle(degrees: self.BEO.canvasRotation))
        .gesture(dragAngleGestures.simultaneously(with: scaleGestures))
        .onAppear { self.lastOffset = self.BEO.canvasOffset }
    }

    // Pan — mirrors CanvasEngine.dragAngleGestures (counter-rotates the
    // translation so panning tracks the finger when the canvas is rotated).
    private var dragAngleGestures: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if self.BEO.gesturesAreLocked { return }
                let translation = gesture.translation
                let cosAngle = cos(Angle(degrees: self.BEO.canvasRotation).radians)
                let sinAngle = sin(Angle(degrees: self.BEO.canvasRotation).radians)
                let adjustedX = cosAngle * translation.width + sinAngle * translation.height
                let adjustedY = -sinAngle * translation.width + cosAngle * translation.height
                let offsetX = self.lastOffset.x + (adjustedX / self.BEO.canvasScale)
                let offsetY = self.lastOffset.y + (adjustedY / self.BEO.canvasScale)
                self.BEO.canvasOffset = CGPoint(x: offsetX, y: offsetY)
            }
            .onEnded { _ in self.lastOffset = self.BEO.canvasOffset }
            .updating($dragOffset) { value, state, _ in state = value.translation }
    }

    // Zoom — mirrors CanvasEngine.scaleGestures (clamped to BEO min/max).
    private var scaleGestures: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if self.BEO.gesturesAreLocked { return }
                let delta = value / self.BEO.lastScaleValue
                self.BEO.canvasScale = min(max(self.BEO.canvasScale * delta,
                                               BoardEngineObject.minCanvasScale),
                                           BoardEngineObject.maxCanvasScale)
                self.BEO.lastScaleValue = value
            }
            .onEnded { _ in self.BEO.lastScaleValue = 1.0 }
    }
}
