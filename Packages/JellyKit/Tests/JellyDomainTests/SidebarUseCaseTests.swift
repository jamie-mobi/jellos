//
//  SidebarUseCaseTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import Testing

@Suite("SidebarUseCase", .tags(.domain))
struct SidebarUseCaseTests {

    // MARK: - Fixtures

    private static let libraries = [
        Library(id: "movies", name: "Movies", kind: .movies),
        Library(id: "shows", name: "Shows", kind: .shows)
    ]

    // MARK: - Shortcuts

    @Test(

        arguments: [
            (1, SidebarItem.home),
            (2, SidebarItem.library("movies")),
            (3, SidebarItem.library("shows"))
        ]
    )
    func `Command-1 is Home and Command-2 and on are libraries in sidebar order`(number: Int, expected: SidebarItem) {
        #expect(SidebarUseCase.item(forShortcut: number, libraries: Self.libraries) == expected)
    }

    @Test(arguments: [0, 4, 10])
    func `a shortcut past the last library does nothing`(number: Int) {
        #expect(SidebarUseCase.item(forShortcut: number, libraries: Self.libraries) == nil)
    }

    // MARK: - Restore

    @Test
    func `a saved library that still exists is restored`() {
        #expect(SidebarUseCase.restored(.library("shows"), libraries: Self.libraries) == .library("shows"))
    }

    @Test
    func `a saved library that is gone falls back to Home`() {
        #expect(SidebarUseCase.restored(.library("gone"), libraries: Self.libraries) == .home)
    }

    @Test(arguments: [
        (SidebarItem?.none, SidebarItem.home),
        (SidebarItem.favorites, SidebarItem.favorites)
    ])
    func `nothing saved is Home, and Favorites is kept`(saved: SidebarItem?, expected: SidebarItem) {
        #expect(SidebarUseCase.restored(saved, libraries: Self.libraries) == expected)
    }

    // MARK: - Storage key

    @Test(arguments: [
        SidebarItem.home,
        .favorites,
        .library("movies")
    ])
    func `an item survives a round trip through its storage key`(item: SidebarItem) {
        #expect(SidebarItem(storageKey: item.storageKey) == item)
    }
}
