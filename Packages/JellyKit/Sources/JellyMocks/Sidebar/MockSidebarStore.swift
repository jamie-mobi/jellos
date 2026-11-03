//
//  MockSidebarStore.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Synchronization

#if DEBUG
public final class MockSidebarStore: SidebarStoreProtocol, Sendable {

    // MARK: - Private

    private let item = Mutex<SidebarItem?>(nil)

    // MARK: - Init

    public init() {}

    // MARK: - SidebarStoreProtocol

    public func load() -> SidebarItem? {
        item.withLock { $0 }
    }

    public func save(_ item: SidebarItem) {
        self.item.withLock { $0 = item }
    }
}
#endif
