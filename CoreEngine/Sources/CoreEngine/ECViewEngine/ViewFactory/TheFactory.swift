//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/19/24.
//

import Foundation
import SwiftUI

public extension CoreName {
    class Views {
        public enum NavStackChild: String, CaseIterable {
            case signupProfile = "signupProfile"
            case chat = "chat"
            public var name: String {rawValue}
        }
        public enum SideBarCompanion: String, CaseIterable {
            case buddyList = "buddyList"
            public var name: String {rawValue}
        }
        public enum Panel: String, CaseIterable {
            case notification = "notification"
            case mode = "mode"
            case tipBox = "tipBox"
            public var name: String {rawValue}
        }
    }
}

public class ViewFactory {
    public static func HoldView<C: View>(_ view: C) -> () -> C { return { view } }
    public static func HoldView<C: View>(_ view: C) -> C { return view }
    public static func HoldView<C: View>(_ view: C) -> () -> AnyView { return { AnyView(view) } }
    public static func HoldView<C: View>(_ view: C) -> AnyView { return AnyView(view) }

    public static func BuildManagedHolder<Content: View, Side: View>(callerId: String, @ViewBuilder mainContent: @escaping () -> Content, @ViewBuilder sideContent: @escaping () -> Side) -> ManagedViewHolder {
        return ManagedViewHolder(id: callerId, mainBuilder: { mainContent() }, sidebarBuilder: { sideContent() } )
    }
    
    public struct ViewEngineBuilder: View {
        public var genre: ViewEngine.Genre
        public var viewId: String
        public var activityId: String
        
        public init(genre: ViewEngine.Genre, viewId: String = UUID().uuidString, activityId: String = "SOL") {
            self.genre = genre
            self.viewId = viewId
            self.activityId = activityId
        }

        public var body: some View {
            ViewEngine.GenreBuilder(for: genre, viewId: viewId, activityId: activityId)
        }
    }
}

/*
    :TOOL BUILDER:
 */



// MARK: Final SubType
public struct VEBasicTypeBuilder {
    
    @ViewBuilder
    public static func soccer(with subtype: String) -> some View {
        Image(subtype).resizable()
    }

}


