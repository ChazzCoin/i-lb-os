//
//  CoreListLoader.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/25/26.
//


import SwiftUI

// MARK: - Protocol

protocol CoreListLoader: ObservableObject {
    associatedtype RowData: Identifiable
    var displayedItems: [RowData] { get }
    var isLoading: Bool { get }
    func reload()
}

// MARK: - TableColumn
struct TableColumn<Object: Identifiable>: Identifiable {
    let id = UUID()
    var objId: String = ""
    let title: String
    let filter: String
    let minWidth: CGFloat
    let alignment: Alignment
    let cellContent: (Object) -> AnyView
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

