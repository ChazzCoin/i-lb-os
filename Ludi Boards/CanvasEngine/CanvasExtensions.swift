//
//  CanvasExtensions.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/4/24.
//

import Foundation
import Combine


func postNotification(message: String, icon: String="bell") {
    print("Posting Notification: \(message)")
    CodiChannel.ON_NOTIFICATION.send(value: NotificationController(message: message, icon: icon))
}
