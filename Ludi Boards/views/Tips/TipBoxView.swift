//
//  TipBoxView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 12/2/23.
//

import Foundation
import SwiftUI

struct TipBoxView: View {
    var tips: [String]
    @State private var isFlashing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tips & Features")
                        .font(.headline)
                    
                    Text("Line Drawing Mode")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 15, height: 15)
                    .opacity(isFlashing ? 1 : 0)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            isFlashing.toggle()
                        }
                    }
            }

            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .frame(width: 12, height: 12)
                        .foregroundColor(.blue)
                        .padding(.top, 5)

                    Text(tip)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemBackground))
            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4))
        .padding()
        
    }
}


struct TipBoxViewFlasher: View {
    var tips: [String]
    var disableCallback: () -> Void
    @State private var isFlashing = false
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tips & Features")
                        .font(.headline)
                        .onTapGesture {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                    
                    Text("Line Drawing Mode")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 15, height: 15)
                    .opacity(isFlashing ? 1 : 0)
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            isFlashing.toggle()
                        }
                    }
            }

            if isExpanded {
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(tips, id: \.self) { tip in
                            HStack(alignment: .top) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.blue)
                                    .padding(.top, 5)

                                Text(tip)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.horizontal) // Adjust padding as needed
                }
                
            }
            
            Button(action: {
                // Add code here to "Turn Off" the feature
                disableCallback()
            }) {
                Text("Turn Off")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: 300, maxHeight: UIScreen.main.bounds.height - 100)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemBackground))
            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4))
        .padding()
//        .offset(y: self.isExpanded ? 0 : -150)
    }
}



struct TipBoxViewStaticPanel: View {
    var tips: [String]
    var subTitle: String
    var disableCallback: () -> Void
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tips & Features")
                        .font(.headline)
                        .onTapGesture {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                    
                    Text(subTitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

            }

            if isExpanded {
                ForEach(tips, id: \.self) { tip in
                    HStack(alignment: .top) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .frame(width: 12, height: 12)
                            .foregroundColor(.blue)
                            .padding(.top, 5)

                        Text(tip)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            Button(action: {
                // Add code here to "Turn Off" the feature
                disableCallback()
            }) {
                Text("Close")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: 350)
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(UIColor.systemBackground))
            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4))
        .padding()
//        .offset(y: self.isExpanded ? 0 : 0)
    }
}



struct TipBoxView_Previews: PreviewProvider {
    static var previews: some View {
        TipBoxView(tips: [
            "Swipe left to delete an item.",
            "Tap on a task to mark it complete.",
            "Long press to open task options.",
            "Double tap to edit a task."
        ])
    }
}


