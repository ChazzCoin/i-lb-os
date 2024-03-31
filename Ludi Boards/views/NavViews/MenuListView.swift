//
//  MenuListView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 3/30/24.
//

import Foundation
import SwiftUI

enum ActiveSheet: Identifiable {
    case profile, settings, addOrg, addTeam, addPlayer, addSession, addActivity

    var id: Int {
        switch self {
            case .profile:
                return 0
            case .settings:
                return 1
            case .addOrg:
                return 2
            case .addTeam:
                return 3
            case .addPlayer:
                return 4
            case .addSession:
                return 5
            case .addActivity:
                return 6
        }
    }
}

struct MenuListView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var isShowing: Bool
    @State private var isEditBusViewShowing = false
    @State private var activeSheet: ActiveSheet?
    @State private var showAlert = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Menu")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 16)
                .padding(.leading, 20)
            
            ForEach(MenuOption.allCases, id: \.self) { option in
                Button(action: {
                    switch option {
                        case .profile:
                            activeSheet = .profile
                        case .addOrg:
                            activeSheet = .addOrg
                        case .addTeam:
                            activeSheet = .addTeam
                        case .addPlayer:
                            activeSheet = .addPlayer
                        case .addSession:
                            activeSheet = .addSession
                        case .addActivity:
                            activeSheet = .addActivity
                        case .settings:
                            activeSheet = .settings
                        case .signOut:
                            showAlert = true
                    }
                }) {
                    MenuOptionView(option: option)
                }
            }
            .sheet(item: $activeSheet) { item in
                switch item {
                    case .profile:
                        SignUpView()
                    case .settings:
                        EmptyView()
                    case .addOrg:
                        EmptyView()
                    case .addTeam:
                        TeamView(teamId: .constant("new"), isShowing: .constant(true))
                    case .addPlayer:
                        PlayerRefView(playerId: .constant("new"), isShowing: .constant(true))
                    case .addSession:
                        SessionPlanView(sessionId: "new", isShowing: .constant(true), isMasterWindow: false)
                    case .addActivity:
                        EmptyView()
                }
            }

            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Sign Out"),
                    message: Text("Are you sure you want to sign out?"),
                    primaryButton: .destructive(Text("Yes")) {
                        UserTools.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .padding(.leading, 20)
        .frame(width: 300, height: UIScreen.main.bounds.height, alignment: .leading)
        .background(getBackgroundGradient(colorScheme))
        .edgesIgnoringSafeArea(.all)
        .transition(.move(edge: .leading))
        
    }
    

    
    
    struct MenuOptionView: View {
        let option: MenuOption
        
        var body: some View {
            HStack {
                Image(systemName: option.iconName)
                    .foregroundColor(.gray)
                    .imageScale(.large)
                Text(option.title)
                    .foregroundColor(option == .signOut ? .red : .black)
                    .font(.headline)
            }
            .padding(.vertical, 10)
        }
    }
    
    enum MenuOption: CaseIterable {
        case profile
        case addOrg
        case addTeam
        case addPlayer
        case addSession
        case addActivity
        case settings
        case signOut
        
        var title: String {
            switch self {
                case .profile: return "Profile"
                case .addOrg: return "Add Organization"
                case .addTeam: return "Add Team"
                case .addPlayer: return "Add Player"
                case .addSession: return "Add Session"
                case .addActivity: return "Add Activity"
                case .settings: return "Settings"
                case .signOut: return "Sign Out"
            }
        }
        
        var iconName: String {
            switch self {
                case .profile: return "person"
                case .addOrg: return "plus"
                case .addTeam: return "plus"
                case .addPlayer: return "plus"
                case .addSession: return "plus"
                case .addActivity: return "plus"
                case .settings: return "gear"
                case .signOut: return "arrow.backward.square"
            }
        }
    }
}
