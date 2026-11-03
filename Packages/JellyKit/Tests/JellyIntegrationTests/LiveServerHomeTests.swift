//
//  LiveServerHomeTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain
import Testing

@Suite("Live server Home", .enabled(if: LiveServer.isConfigured))
struct LiveServerHomeTests {

    // MARK: - Types

    private struct UserDTO: Decodable {
        let Id: String
    }

    // MARK: - Tests

    @Test
    func `Next Up and Latest decode from the live server and give at least one featured item`() async throws {
        let host = try #require(LiveServer.host)
        let key = try #require(LiveServer.apiKey)
        let address = try ServerAddressUseCase.normalize(host.absoluteString)
        let urlSession = URLSession(configuration: .ephemeral)
        var request = try URLRequest(url: #require(URL(string: address.absoluteString + "/Users")))
        request.setValue(
            #"MediaBrowser Client="jellyOS", Device="Tests", DeviceId="jellyos-integration-tests", Version="0.1", Token="\#(key)""#,
            forHTTPHeaderField: "Authorization"
        )
        let userID = try await JSONDecoder().decode([UserDTO].self, from: urlSession.data(for: request).0)[0].Id
        let session = Session(
            server: Server(id: "live", name: "Live", version: "", address: address),
            user: User(id: userID, name: "", hasPassword: true, imageURL: nil),
            accessToken: key
        )
        let repository = HomeRepository(
            urlSession: urlSession,
            identity: ClientIdentity(client: "jellyOS", device: "Tests", deviceID: "jellyos-integration-tests", version: "0.1")
        )

        let nextUp = try await repository.nextUp(session: session)
        let latest = try await repository.latest(session: session)
        let featured = FeaturedUseCase.featured(nextUp: nextUp, latest: latest)

        #expect(latest.isEmpty == false)
        #expect(featured.isEmpty == false)
        #expect(featured.allSatisfy { $0.backdropURL != nil })
    }
}
