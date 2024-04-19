//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/13/24.
//

import Foundation
import SwiftUI

// Master VIEW MODE
public struct TextLabel: View {
    @State public var title: String
    @State public var subtitle: String
    
    public init(_ title: String, text: String) {
        self.title = title
        self.subtitle = text
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.trailing)
            Spacer()
            Text(subtitle)
                .font(.headline)
                .foregroundColor(.black)
        }
        .onAppear() {
            if subtitle.isEmpty {
                self.subtitle = "Empty"
            }
        }
    }
}
