//
//  Sheets.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 7/30/24.
//

import Foundation
import SwiftUI
import CoreEngine

// Custom Sheet Modifier
struct SheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, content: sheetContent)
    }
}

struct OrganizationDetailsSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var reset: Bool
    var orgId: String

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                OrganizationDetailsView(orgId: orgId, reset: $reset)
            }
    }
}

struct TeamSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var teamId: String

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                TeamView(teamId: $teamId, isShowing: $isPresented)
            }
    }
}

struct PlayerRefSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var playerId: String

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                PlayerRefView(playerId: $playerId, isShowing: $isPresented)
            }
    }
}

struct ActivitySheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    var activityId: String
    @ObservedObject var BEO: BoardEngineObject

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ActivityPlanSingleView(activityId: activityId)
                    .environmentObject(self.BEO)
            }
    }
}

// Extension for easy usage
extension View {
    
    func activityPlanSheet(isPresented: Binding<Bool>, activityId: String, BEO: BoardEngineObject) -> some View {
        self.modifier(ActivitySheetModifier(isPresented: isPresented, activityId: activityId, BEO: BEO))
    }
    
    func organizationDetailsSheet(isPresented: Binding<Bool>, orgId: String, reset: Binding<Bool>) -> some View {
        self.modifier(OrganizationDetailsSheetModifier(isPresented: isPresented, reset: reset, orgId: orgId))
    }

    func teamSheet(isPresented: Binding<Bool>, teamId: Binding<String>) -> some View {
        self.modifier(TeamSheetModifier(isPresented: isPresented, teamId: teamId))
    }
    
    func playerRefSheet(isPresented: Binding<Bool>, playerId: Binding<String>) -> some View {
        self.modifier(PlayerRefSheetModifier(isPresented: isPresented, playerId: playerId))
    }
    
    func customSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(SheetModifier(isPresented: isPresented, sheetContent: content))
    }
}
