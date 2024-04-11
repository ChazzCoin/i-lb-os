//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/9/24.
//

import Foundation
import SwiftUI

public struct BulletPointPanel: View {
    public var bulletPoints: [String]
    public var disableCallback: () -> Void
    @State public var isFlashing = false
    @State public var isExpanded = true
    
    public init(bulletPoints: [String], disableCallback: @escaping () -> Void, isFlashing: Bool = false, isExpanded: Bool = true) {
        self.bulletPoints = bulletPoints
        self.disableCallback = disableCallback
        self.isFlashing = isFlashing
        self.isExpanded = isExpanded
    }

    public var body: some View {
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
                        ForEach(bulletPoints, id: \.self) { tip in
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

