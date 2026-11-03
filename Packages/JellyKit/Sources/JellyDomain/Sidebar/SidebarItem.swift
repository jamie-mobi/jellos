//
//  SidebarItem.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum SidebarItem: Hashable, Sendable {
    case home
    case library(String)
    case favorites

    // MARK: - Constants

    private static let libraryPrefix = "library:"

    // MARK: - Storage

    public init?(storageKey: String) {
        switch storageKey {
        case "home":
            self = .home
        case "favorites":
            self = .favorites
        case let key where key.hasPrefix(Self.libraryPrefix):
            self = .library(String(key.dropFirst(Self.libraryPrefix.count)))
        default:
            return nil
        }
    }

    public var storageKey: String {
        switch self {
        case .home:
            "home"
        case .favorites:
            "favorites"
        case let .library(id):
            Self.libraryPrefix + id
        }
    }
}
