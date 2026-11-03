//
//  SidebarService.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Observation

@MainActor
@Observable
public final class SidebarService {

    // MARK: - State

    public private(set) var libraries: [Library] = []
    public private(set) var selection: SidebarItem = .home
    public private(set) var hasLoaded = false

    // MARK: - Private

    private let repository: any LibraryRepositoryProtocol
    private let store: any SidebarStoreProtocol

    // MARK: - Init

    public init(repository: any LibraryRepositoryProtocol, store: any SidebarStoreProtocol) {
        self.repository = repository
        self.store = store
    }

    // MARK: - Intent

    public func start(session: Session) async {
        let loaded: [Library]
        do {
            loaded = try await repository.libraries(session: session)
        } catch {
            loaded = []
        }

        libraries = loaded
        selection = SidebarUseCase.restored(store.load(), libraries: loaded)
        hasLoaded = true
    }

    public func select(_ item: SidebarItem) {
        guard item != selection else {
            return
        }

        selection = item
        store.save(item)
    }

    public func selectShortcut(_ number: Int) {
        guard let item = SidebarUseCase.item(forShortcut: number, libraries: libraries) else {
            return
        }

        select(item)
    }
}
