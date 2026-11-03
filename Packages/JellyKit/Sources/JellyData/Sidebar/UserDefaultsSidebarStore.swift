//
//  UserDefaultsSidebarStore.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public final class UserDefaultsSidebarStore: SidebarStoreProtocol, Sendable {

    // MARK: - Constants

    private static let key = "sidebarSelection"

    // MARK: - Private

    private let suiteName: String?

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    // MARK: - Init

    public init(suiteName: String?) {
        self.suiteName = suiteName
    }

    // MARK: - SidebarStoreProtocol

    public func load() -> SidebarItem? {
        defaults.string(forKey: Self.key).flatMap(SidebarItem.init(storageKey:))
    }

    public func save(_ item: SidebarItem) {
        defaults.set(item.storageKey, forKey: Self.key)
    }
}
