//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import SwiftUI


public struct ModePanel: View {
    @State public var title: String
    @State public var subTitle: String
    @State public var showButton: Bool
    public var onStop: () -> Void
    @State public var showImage: Bool = false
    @State public var imageName: String = "play"
    @State public var isFlashing = false
    
    public init(title: String, subTitle: String, showButton: Bool, onStop: @escaping () -> Void = {}, isFlashing: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.showButton = showButton
        self.onStop = onStop
        self.isFlashing = isFlashing
    }

    public init(title: String, subTitle: String, showButton: Bool, showImage: Bool, imageName: String = "play", onStop: @escaping () -> Void = {}, isFlashing: Bool = false) {
        self.title = title
        self.subTitle = subTitle
        self.showButton = showButton
        self.showImage = showImage
        self.imageName = imageName
        self.onStop = onStop
        self.isFlashing = isFlashing
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    
                    Text(subTitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
                
                if showImage {
                    Image(systemName: imageName)
                        .resizable()
                        .frame(width: 15, height: 15)
                        .opacity(isFlashing ? 1 : 0)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                isFlashing.toggle()
                            }
                        }
                } else {
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
                
            }
            if showButton {
                Button(action: {
                    onStop()
                }) {
                    Text("Stop")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(8)
                }
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
