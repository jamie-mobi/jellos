//
//  MemorySidebarStore.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Synchronization

final class MemorySidebarStore: SidebarStoreProtocol {
    private let item: Mutex<SidebarItem?>

    init(_ item: SidebarItem? = nil) {
        self.item = Mutex(item)
    }

    func load() -> SidebarItem? {
        item.withLock { $0 }
    }

    func save(_ item: SidebarItem) {
        self.item.withLock { $0 = item }
    }
}
