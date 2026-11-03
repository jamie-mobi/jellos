//
//  ServerListServiceTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain
import JellyServices
import Testing

@Suite("ServerListService", .tags(.service))
struct ServerListServiceTests {
    private static let server = Server(
        id: "abc",
        name: "Den",
        version: "10.11.0",
        address: URL(string: "http://den.local:8096")!
    )

    @Test
    func `the list is empty before reload`() async {
        let sut = await ServerListService(repository: StubServerRepository(saved: [Self.server]))

        #expect(await sut.servers.isEmpty)
    }

    @Test
    func `reload shows the saved servers`() async {
        let sut = await ServerListService(repository: StubServerRepository(saved: [Self.server]))

        await sut.reload()

        #expect(await sut.servers == [Self.server])
    }

    @Test
    func `reload picks up a server saved after the first load`() async {
        let repository = StubServerRepository()
        let sut = await ServerListService(repository: repository)
        await sut.reload()

        await repository.save(Self.server)
        await sut.reload()

        #expect(await sut.servers == [Self.server])
    }
}
