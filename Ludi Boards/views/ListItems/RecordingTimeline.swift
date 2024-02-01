//
//  RecordingTimeline.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/31/24.
//

import Foundation
import SwiftUI

struct TimelineListView: View {
    let recordings: [Recording]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 8) {
                ForEach(recordings) { recording in
//                    TimelineItemView(recording: recording)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 20)
        }
        .frame(height: 100) // Adjust based on your design
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct TimelineItemView: View {
    let recording: RecordingAction
    
    var body: some View {
        VStack {
            Text("Action")
                .font(.headline)
                .padding(.top, 5)
            Text(String(recording.orderIndex))
                .font(.caption)
                .padding(.bottom, 5)
        }
        .frame(width: 50)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}
