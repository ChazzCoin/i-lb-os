//
//  LazyRow.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 11/15/23.
//

import Foundation
import SwiftUI

struct LazyRow: View {
    var contentList: [ViewWrapper]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 20) {
                ForEach(contentList) { item in
                    item.view()
                }
            }
            .padding()
        }
    }
}

struct LazyColumn: View {
    var contentList: [ViewWrapper]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(contentList) { item in
                    item.view()
                }
            }
            .padding()
        }
    }
}
