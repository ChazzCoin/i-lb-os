//
//  CanvasExtensions.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/4/24.
//

import Foundation
import Combine
import CoreEngine
import SwiftUI

func postNotification(message: String, icon: String="bell") {
    print("Posting Notification: \(message)")
    CodiChannel.ON_NOTIFICATION.send(value: NotificationController(message: message, icon: icon))
}
extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

