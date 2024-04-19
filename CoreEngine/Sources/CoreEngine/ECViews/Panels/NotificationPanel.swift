//
//  NotificationView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/15/24.
//

import SwiftUI
import AudioToolbox

public struct NotificationPanel: View {
    @State public var message: String
    @State public var icon: String
    
//    public init(message: Binding<String>, icon: Binding<String>) {
//        self._message = message
//        self._icon = icon
//    }
    
    public init(message: String, icon: String) {
        self.message = message
        self.icon = icon
    }
    
    public let iconDoorOpen = "door_open"
    public let iconDoorClose = "door_closed"
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Notification")
                        .font(.headline)
//                        .foregroundColor(.primaryBackground)
                        .onTapGesture {
                            withAnimation {
                                //isExpanded.toggle()
                            }
                        }
                }
            }

            HStack(alignment: .top) {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
//                    .foregroundColor(.primaryBackground)
                    .frame(width: 20, height: 20)

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding()
        
        }
        .padding()
        .frame(maxWidth: 350)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemBackground))
            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4))
        .padding()
        .onAppear() {
            AudioServicesPlaySystemSound(1007)
        }
    }
}


