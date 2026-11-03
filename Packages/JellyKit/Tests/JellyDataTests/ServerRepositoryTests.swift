//
//  ServerRepositoryTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("ServerRepository", .tags(.data))
struct ServerRepositoryTests {

    // MARK: - Doubles

    private struct StubTransport: ServerInfoHTTPTransportProtocol {
        let result: Result<PublicSystemInfoDTO, ConnectError>

        func fetchPublicSystemInfo(server: URL) async throws(ConnectError) -> PublicSystemInfoDTO {
            try result.get()
        }
    }

    // MARK: - Fixtures

    private static let address = URL(string: "http://den.local:8096")!

    private func makeStore() -> UserDefaultsServerStore {
        UserDefaultsServerStore(suiteName: "test.\(UUID().uuidString)")
    }

    // MARK: - Tests

    @Test
    func `fetchServer maps the public info to a server at the given address`() async throws {
        let dto = PublicSystemInfoDTO(serverName: "Den", version: "10.11.0", id: "abc")
        let sut = ServerRepository(transport: StubTransport(result: .success(dto)), store: makeStore())

        let server = try await sut.fetchServer(at: Self.address)

        #expect(server == Server(id: "abc", name: "Den", version: "10.11.0", address: Self.address))
    }

    @Test
    func `fetchServer passes the transport error through`() async {
        let sut = ServerRepository(transport: StubTransport(result: .failure(.network)), store: makeStore())

        await #expect(throws: ConnectError.network) {
            _ = try await sut.fetchServer(at: Self.address)
        }
    }

    @Test
    func `save adds a new server and replaces one with the same id`() async throws {
        let sut = ServerRepository(transport: StubTransport(result: .failure(.network)), store: makeStore())
        let first = Server(id: "abc", name: "Den", version: "1", address: Self.address)
        let other = try Server(id: "xyz", name: "Office", version: "1", address: #require(URL(string: "http://office.local")))
        let moved = try Server(id: "abc", name: "Den", version: "2", address: #require(URL(string: "https://den.example.com")))

        await sut.save(first)
        await sut.save(other)
        await sut.save(moved)

        #expect(await sut.savedServers() == [moved, other])
    }
}
