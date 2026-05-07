//
//  ConnectionListLoader.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/25/26.
//

import SwiftUI
import RealmSwift

public struct ConnectionRowData: Identifiable, Hashable {
    public let id: String
    public let userOne: String
    public let userTwo: String
    public let connection: String
    public let status: String
    public let dateUpdated: String
}


@MainActor
public class ConnectionListObservable: ObservableObject {

    // MARK: - Published
    @Published public var displayedItems: [ConnectionRowData] = []
    @Published public var isLoading: Bool = false
    @Published public var searchText: String = ""

    // MARK: - Paging
    public let pageSize: Int = 50
    public var currentPage: Int = 1

    // MARK: - Reload
    public func reload(reset: Bool = true) {
        if reset {
            currentPage = 1
            displayedItems.removeAll()
        }
        loadPage()
    }

    // MARK: - Load Page
    public func loadPage() {
        guard !isLoading else { return }
        isLoading = true

        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        DispatchQueue.global(qos: .userInitiated).async {
            let realm = newRealm()
            var results = realm.objects(Connection.self)

            if !search.isEmpty {
                results = results.filter(
                    "userOne CONTAINS[c] %@ OR userTwo CONTAINS[c] %@",
                    search, search
                )
            }

            let slice = results
                .sorted(byKeyPath: "dateUpdated", ascending: false)
                .dropFirst((self.currentPage - 1) * self.pageSize)
                .prefix(self.pageSize)

            let rows = slice.map {
                ConnectionRowData(
                    id: $0.id,
                    userOne: $0.userOne,
                    userTwo: $0.userTwo,
                    connection: $0.connection,
                    status: $0.status,
                    dateUpdated: $0.dateUpdated
                )
            }

            DispatchQueue.main.async {
                self.displayedItems.append(contentsOf: rows)
                self.currentPage += 1
                self.isLoading = false
            }
        }
    }
}
