//
//  TwoFingerPanView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/20/23.
//

import Foundation
import UIKit
import SwiftUI

//class TwoFingerPanView: UIView {
//    var onPan: ((CGPoint) -> Void)?
//
//    private lazy var panRecognizer: UIPanGestureRecognizer = {
//        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
//        recognizer.minimumNumberOfTouches = 2
//        recognizer.maximumNumberOfTouches = 2
//        return recognizer
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addGestureRecognizer(panRecognizer)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    @objc private func panned(_ recognizer: UIPanGestureRecognizer) {
//        let translation = recognizer.translation(in: self)
//        onPan?(translation)
//        recognizer.setTranslation(.zero, in: self)
//    }
//}
//
//struct TwoFingerPanGestureView: UIViewRepresentable {
//    var onPan: (CGPoint) -> Void
//
//    func makeUIView(context: Context) -> TwoFingerPanView {
//        let view = TwoFingerPanView()
//        view.onPan = onPan
//        return view
//    }
//
//    func updateUIView(_ uiView: TwoFingerPanView, context: Context) {
//        // Update the view if necessary
//    }
//}
