//
//  TabView.swift
//  Ludi Boards
//
//  Created by Charles Romeo on 1/18/24.
//

import SwiftUI

struct TabItem: Identifiable {
    var id: String { title }
    let title: String
    let view: AnyView
}

struct DynamicTabView: View {
    var items: [TabItem]
    var selectedTab: TabItem

    init(items: [TabItem]) {
        self.items = items
        self.selectedTab = items.first ?? TabItem(title: "", view: AnyView(Text("")))
    }

    var body: some View {
        Group {
            // Tab Bar
            HStack {
                ForEach(items, id: \.id) { item in
                    SolButton(title: item.title, action: {
//                        self.selectedView = item.view
//                        self.selectedTab = item
                    })
                    Spacer()
                }
            }
            .padding()

            // Content Area
            VStack {
                self.selectedTab.view
//                ForEach(items, id: \.id) { item in
//                    if item.title == selectedTab {
//                        item.view
//                    }
//                }
            }
            .frame(minHeight: 500)
            .padding()
        }
    }
}


//#Preview {
//    TabView()
//}
