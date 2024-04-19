//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/18/24.
//

import Foundation
import SwiftUI

public struct ThoughtView: View {
    @Binding public var curFilter: String
    @Binding public var filterIsOn: Bool
    @State public var thought: Thought
    @State public var message: String
    @State public var likeCount: Int
    @State public var screenHeight: CGFloat
    @State public var startTime: Date
    @State public var endTime: Date
    @State public var yOffset: CGFloat = 0
    @State public var xOffset = CGFloat.random(in: 100...UIScreen.main.bounds.width-100)
    @State public var fontSize = 14.0
    @State public var isVisible: Bool = true
    @State public var isEnabled: Bool = true
    @State public var fontColor: Color = DateTimeTools.isDaytime() ? Color.black : Color.white
    @State public var viewSize: CGSize = .zero  // Store the view size
    @State public var viewZIndex: CGFloat = CGFloat.random(in: 1.0...7.0)
    @State public var viewIsActive: Bool = false
    
    @State public var hasBeenLiked: Bool = false
    
//    @StateObject var thoughtsObserver = FirebaseThoughtsService()
    
    public let moodGradients: [String: LinearGradient] = [
        "General": LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom),
        "Happy": LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .top, endPoint: .bottom),
        "Sad": LinearGradient(gradient: Gradient(colors: [.blue, .gray]), startPoint: .top, endPoint: .bottom),
        "Angry": LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom),
        "Anxious": LinearGradient(gradient: Gradient(colors: [.purple, .gray]), startPoint: .top, endPoint: .bottom),
        "Excited": LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom),
        "Grateful": LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .top, endPoint: .bottom),
        "Hopeful": LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom),
        "Relaxed": LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom),
        "Stressed": LinearGradient(gradient: Gradient(colors: [.gray, .red]), startPoint: .top, endPoint: .bottom),
        "Confused": LinearGradient(gradient: Gradient(colors: [.purple, .pink]), startPoint: .top, endPoint: .bottom),
        "Disappointed": LinearGradient(gradient: Gradient(colors: [.gray, .black]), startPoint: .top, endPoint: .bottom),
        "Inspired": LinearGradient(gradient: Gradient(colors: [.pink, .orange]), startPoint: .top, endPoint: .bottom),
        "Lonely": LinearGradient(gradient: Gradient(colors: [.black, .blue]), startPoint: .top, endPoint: .bottom),
        "Proud": LinearGradient(gradient: Gradient(colors: [.purple, .red]), startPoint: .top, endPoint: .bottom),
        "Curious": LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom),
        "Frustrated": LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .top, endPoint: .bottom),
        "Amused": LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .top, endPoint: .bottom),
        "Overwhelmed": LinearGradient(gradient: Gradient(colors: [.red, .purple]), startPoint: .top, endPoint: .bottom),
        "Content": LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom)
    ]
    
    // Function to get gradient based on mood
    public func getGradient(forMood mood: String) -> LinearGradient {
        moodGradients[mood] ?? LinearGradient(gradient: Gradient(colors: [.black, .white]), startPoint: .top, endPoint: .bottom)
    }
    
    public var backgroundStyle: LinearGradient {
        return viewIsActive ? LinearGradient(
            gradient: Gradient(colors: [
                Color.gray.opacity(0.9),
                Color.gray,
                Color.gray.opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        ) :
        getGradient(forMood: thought.category)
//        LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.4), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
    }

    public var body: some View {
           GeometryReader { geometry in
               ScrollView {
                   Text(message)
                       .font(.system(size: fontSize))
                       .foregroundColor(fontColor)
                       .padding()
                       .fixedSize(horizontal: false, vertical: true)
               }
               .background(backgroundStyle)
               .clipShape(ThoughtBubble())
               .cornerRadius(30)
               .shadow(radius: 5)
               .onAppear {
                   viewSize = geometry.size
                   calculateInitialPosition()
                   startAnimation()
               }
               
               // Like Badge
               Text("\(likeCount)")
                   .font(.caption)
                   .fontWeight(.bold)
                   .foregroundColor(.white)
                   .frame(width: 24, height: 24)
                   .background(Color.red)
                   .clipShape(Circle())
                   .offset(x: -10, y: -10)
           }
           .zIndex(viewZIndex)
           .frame(maxWidth: 150, maxHeight: 100)
           .opacity(isVisible && isEnabled ? 1 : 0)
           .position(x: xOffset, y: yOffset)
           .onChange(of: filterIsOn) { _ in
               if filterIsOn {
                   self.isEnabled = curFilter == thought.category
               } else {
                   self.isEnabled = true
               }
           }
           .onChange(of: curFilter) { newFilter in
               if filterIsOn {
                   self.isEnabled = newFilter == thought.category
               } else {
                   self.isEnabled = true
               }
           }
           .onTap {
               if viewIsActive {
                   viewZIndex = CGFloat.random(in: 1.0...7.0)
                   viewIsActive = false
               } else {
                   viewZIndex = 10.0
                   viewIsActive = true
               }
           }.simultaneousGesture(TapGesture(count: 2).onEnded({ _ in
               print("Tapped double")
               if hasBeenLiked { return }
//               newRealm().safeWrite { r in
//                   if let temp = thought.thaw() {
//                       temp.likes = temp.likes + 1
//                       firebaseDatabase { db in
//                           db.save(collection: "thoughts", id: temp.id, obj: temp)
//                       }
//                   }
//               }
               likeCount = likeCount + 1
               hasBeenLiked = true
            }))
           
           .onAppear {
               
               if let obj = newRealm().findByField(Thought.self, value: thought.id) {
                   likeCount = obj.likes
                   message = obj.message
               }
               
//               thoughtsObserver.startObserving(id: thought.id) { obj in
//                   likeCount = obj.likes
//                   message = obj.message
//               }
               
               likeCount = thought.likes
               xOffset = CGFloat.random(in: viewSize.width/2...UIScreen.main.bounds.width-viewSize.width/2)
           }
           .onDisappear() {
//               thoughtsObserver.stopObserving()
           }
       }

    public func calculateInitialPosition() {
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(startTime)
        let totalDuration = endTime.timeIntervalSince(startTime)
        let speed = screenHeight / CGFloat(totalDuration)
        yOffset = speed * CGFloat(elapsedTime)
    }

    public func startAnimation() {
        let remainingDuration = endTime.timeIntervalSince(Date())
        withAnimation(.linear(duration: remainingDuration)) {
            yOffset = screenHeight
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + remainingDuration) {
            withAnimation {
                isVisible = false
            }
//            firebaseDatabase { db in
//                db.child("thoughts").child(self.thought.id).removeValue()
//            }
        }
    }
}

//public struct ThoughtBubble: Shape {
//    public func path(in rect: CGRect) -> Path {
//        var path = Path()
//
//        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height), cornerSize: CGSize(width: 30, height: 30))
//        path.addRoundedRect(in: CGRect(x: rect.width * 0.6, y: rect.height, width: 20, height: 20), cornerSize: CGSize(width: 10, height: 10))
//        
//        return path
//    }
//}
