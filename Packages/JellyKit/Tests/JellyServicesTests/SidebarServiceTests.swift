//
//  SidebarServiceTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import JellyServices
import Testing

@Suite("SidebarService", .tags(.service))
struct SidebarServiceTests {

    // MARK: - Fixtures

    private static let libraries = [
        Library(id: "movies", name: "Movies", kind: .movies),
        Library(id: "shows", name: "Shows", kind: .shows)
    ]

    // MARK: - Tests

    @Test
    func `start loads the libraries and selects Home when nothing is saved`() async {
        let sut = await SidebarService(
            repository: StubLibraryRepository(result: .success(Self.libraries)),
            store: MemorySidebarStore()
        )

        await sut.start(session: SessionFixtures.session)

        #expect(await sut.libraries == Self.libraries)
        #expect(await sut.selection == .home)
    }

    @Test
    func `start restores the saved selection`() async {
        let sut = await SidebarService(
            repository: StubLibraryRepository(result: .success(Self.libraries)),
            store: MemorySidebarStore(.library("shows"))
        )

        await sut.start(session: SessionFixtures.session)

        #expect(await sut.selection == .library("shows"))
    }

    @Test
    func `select saves the new selection`() async {
        let store = MemorySidebarStore()
        let sut = await SidebarService(repository: StubLibraryRepository(result: .success(Self.libraries)), store: store)
        await sut.start(session: SessionFixtures.session)

        await sut.select(.library("movies"))

        #expect(await sut.selection == .library("movies"))
        #expect(store.load() == .library("movies"))
    }

    @Test
    func `a shortcut number selects the matching row`() async {
        let sut = await SidebarService(
            repository: StubLibraryRepository(result: .success(Self.libraries)),
            store: MemorySidebarStore()
        )
        await sut.start(session: SessionFixtures.session)

        await sut.selectShortcut(3)

        #expect(await sut.selection == .library("shows"))
    }

    @Test
    func `a failed load leaves no libraries and keeps Home`() async {
        let sut = await SidebarService(
            repository: StubLibraryRepository(result: .failure(.network)),
            store: MemorySidebarStore()
        )

        await sut.start(session: SessionFixtures.session)

        #expect(await sut.libraries.isEmpty)
        #expect(await sut.selection == .home)
        #expect(await sut.hasLoaded)
    }
}
