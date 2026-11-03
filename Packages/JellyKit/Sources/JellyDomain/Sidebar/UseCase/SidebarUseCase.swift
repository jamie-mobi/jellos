//
//  SidebarUseCase.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum SidebarUseCase {

    // MARK: - Shortcuts

    public static func item(forShortcut number: Int, libraries: [Library]) -> SidebarItem? {
        guard number != 1 else {
            return .home
        }

        let index = number - 2
        guard libraries.indices.contains(index) else {
            return nil
        }

        return .library(libraries[index].id)
    }

    // MARK: - Restore

    public static func restored(_ saved: SidebarItem?, libraries: [Library]) -> SidebarItem {
        switch saved {
        case nil,
             .home:
            .home
        case .favorites:
            .favorites
        case let .library(id):
            libraries.contains { $0.id == id } ? .library(id) : .home
        }
    }
}
