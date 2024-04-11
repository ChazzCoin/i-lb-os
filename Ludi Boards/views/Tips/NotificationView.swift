////
////  NotificationView.swift
////  Ludi Boards
////
////  Created by Charles Romeo on 1/15/24.
////
//
//import SwiftUI
//import AudioToolbox
//
//struct NotificationView: View {
//    @Binding var message: String
//    @Binding var icon: String
//    
//    init(message: Binding<String>, icon: Binding<String>) {
//        self._message = message
//        self._icon = icon
//    }
//    
//    let iconDoorOpen = "door_open"
//    let iconDoorClose = "door_closed"
//    
//    var body: some View {
//        VStack(alignment: .center, spacing: 0) {
//            HStack {
//                VStack(alignment: .leading, spacing: 3) {
//                    Text("SOL Notification")
//                        .font(.headline)
//                        .foregroundColor(.primaryBackground)
//                        .onTapGesture {
//                            withAnimation {
//                                //                                isExpanded.toggle()
//                            }
//                        }
//                }
//            }
//
//            HStack(alignment: .top) {
//                Image(icon)
//                    .resizable()
//                    .renderingMode(.template)
//                    .foregroundColor(.primaryBackground)
//                    .frame(width: 20, height: 20)
//
//                Text(message)
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.leading)
//                    .fixedSize(horizontal: false, vertical: true)
//            }.padding()
//        
//        }
//        .padding()
//        .frame(maxWidth: 350)
//        .background(RoundedRectangle(cornerRadius: 12)
//            .fill(Color(UIColor.systemBackground))
//            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4))
//        .padding()
//        .onAppear() {
//            AudioServicesPlaySystemSound(1007)
//        }
//    }
//}
//
//#Preview {
//    NotificationView(message: .constant("User has joined the room!"), icon: .constant("door_open"))
//}
