//
//  CoreUserListLoader.swift
//  CoreEngine
//
//  Created by Charles Romeo on 1/25/26.
//

import SwiftUI
import RealmSwift

public struct CoreUserRowData: Identifiable, Hashable {

    public let id: String
    public let name: String
    public let userName: String
    public let handle: String
    public let imgUrl: String
    public let role: String
    public let status: Bool

    public init(
        id: String,
        name: String,
        userName: String,
        handle: String,
        imgUrl: String,
        role: String,
        status: Bool
    ) {
        self.id = id
        self.name = name
        self.userName = userName
        self.handle = handle
        self.imgUrl = imgUrl
        self.role = role
        self.status = status
    }
}


@MainActor
public final class CoreUserListObservable: ObservableObject {

    // MARK: - Published
    @Published public var displayedItems: [CoreUserRowData] = []
    @Published public var isLoading: Bool = false
    @Published public var searchText: String = ""

    // MARK: - Paging
    private let pageSize: Int = 50
    private var currentPage: Int = 1

    // MARK: - Init
    public init() {}

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
            var results = realm.objects(CoreUser.self)

            if !search.isEmpty {
                results = results.filter(
                    "name CONTAINS[c] %@ OR userName CONTAINS[c] %@ OR handle CONTAINS[c] %@",
                    search, search, search
                )
            }

            let slice = results
                .sorted(byKeyPath: "dateUpdated", ascending: false)
                .dropFirst((self.currentPage - 1) * self.pageSize)
                .prefix(self.pageSize)

            let rows = slice.map {
                CoreUserRowData(
                    id: $0.id,
                    name: $0.name,
                    userName: $0.userName,
                    handle: $0.handle,
                    imgUrl: $0.imgUrl,
                    role: $0.role,
                    status: $0.status
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
