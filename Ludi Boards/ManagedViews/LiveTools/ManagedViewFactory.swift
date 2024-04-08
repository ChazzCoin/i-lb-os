//
//  ManagedViewFactory.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 2/3/24.
//

import Foundation
import SwiftUI
import CoreEngine


/*
 1. ViewId = "uuid"
 2. ActivityId = "uuid"
 3. ToolType = "Basic"
 4. SubToolType = "Player"
 */

//func ManagedViewToolFactory(toolType: String, viewId: String, activityId: String) -> AnyView {
//    switch toolType {
//        case "LINE", "DOTTED-LINE":
//            return AnyView(LineDrawingManaged(viewId: viewId, activityId: activityId))
//        case "CURVED-LINE":
//            return AnyView(CurvedLineDrawingManaged(viewId: viewId, activityId: activityId))
//        default:
//            if let view = SoccerToolProvider.parseByTitle(title: toolType)?.getView(viewId: viewId, activityId: activityId) {
//                return view
//            } else {
//                return AnyView(Text("Unsupported tool type"))
//            }
//    }
//}
//
//func ToolIconFactory(toolType: String) -> AnyView {
//    switch toolType {
//        case "LINE", "DOTTED-LINE":
//            return AnyView(LineIconView(isBgColor: true))
//        case "CURVED-LINE":
//            return AnyView(CurvedLineIconView())
//        default:
//            if let temp = SoccerToolProvider.parseByTitle(title: toolType)?.tool.image {
//                return AnyView(ManagedViewBasicToolIcon(toolType: temp))
//            } else {
//                // Return a default view or an error view
//                return AnyView(Text("Unsupported tool type"))
//            }
//    }
//}
