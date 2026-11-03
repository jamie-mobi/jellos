//
//  LiveServerConnectTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain
import Testing

@Suite("Live server connect", .enabled(if: LiveServer.isConfigured))
struct LiveServerConnectTests {
    @Test
    func `the live server answers /System/Info/Public with a name, id and version`() async throws {
        let host = try #require(LiveServer.host)
        let address = try ServerAddressUseCase.normalize(host.absoluteString)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 20
        let repository = ServerRepository(
            urlSession: URLSession(configuration: configuration),
            identity: ClientIdentity(client: "jellyOS", device: "Tests", deviceID: "jellyos-integration-tests", version: "0.1"),
            store: UserDefaultsServerStore(suiteName: "test.\(UUID().uuidString)")
        )

        let server = try await repository.fetchServer(at: address)

        #expect(server.name.isEmpty == false)
        #expect(server.id.isEmpty == false)
        #expect(server.version.isEmpty == false)
        #expect(server.address == address)
    }
}
