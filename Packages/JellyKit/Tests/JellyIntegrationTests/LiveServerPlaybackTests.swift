//
//  LiveServerPlaybackTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain
import Testing

@Suite("Live server playback", .enabled(if: LiveServer.isConfigured))
struct LiveServerPlaybackTests {

    // MARK: - Types

    private struct UserDTO: Decodable {
        let Id: String
    }

    private struct ItemsDTO: Decodable {
        struct Item: Decodable {
            let Id: String
        }

        let Items: [Item]
    }

    // MARK: - Tests

    @Test
    func `PlaybackInfo for a movie gives a stream URL that the server answers`() async throws {
        let host = try #require(LiveServer.host)
        let key = try #require(LiveServer.apiKey)
        let address = try ServerAddressUseCase.normalize(host.absoluteString)
        let urlSession = URLSession(configuration: .ephemeral)

        let userID = try await get([UserDTO].self, "Users", address: address, key: key, urlSession: urlSession)[0].Id
        let items = try await get(
            ItemsDTO.self,
            "Items?userId=\(userID)&recursive=true&includeItemTypes=Movie&limit=1",
            address: address,
            key: key,
            urlSession: urlSession
        )
        let itemID = try #require(items.Items.first?.Id)
        let session = Session(
            server: Server(id: "live", name: "Live", version: "", address: address),
            user: User(id: userID, name: "", hasPassword: true, imageURL: nil),
            accessToken: key
        )
        let repository = PlaybackRepository(
            urlSession: urlSession,
            identity: ClientIdentity(client: "jellyOS", device: "Tests", deviceID: "jellyos-integration-tests", version: "0.1")
        )

        let source = try await repository.playbackSource(itemID: itemID, startTicks: 0, session: session)

        var request = URLRequest(url: source.url)
        request.setValue("bytes=0-1023", forHTTPHeaderField: "Range")
        let (_, response) = try await urlSession.data(for: request)
        let status = try #require(response as? HTTPURLResponse).statusCode
        #expect((200 ..< 300).contains(status))
    }

    // MARK: - Helpers

    private func get<T: Decodable>(
        _ type: T.Type,
        _ path: String,
        address: URL,
        key: String,
        urlSession: URLSession
    ) async throws -> T {
        let url = try #require(URL(string: address.absoluteString + "/" + path))
        var request = URLRequest(url: url)
        request.setValue(
            #"MediaBrowser Client="jellyOS", Device="Tests", DeviceId="jellyos-integration-tests", Version="0.1", Token="\#(key)""#,
            forHTTPHeaderField: "Authorization"
        )
        let (data, _) = try await urlSession.data(for: request)
        return try JSONDecoder().decode(type, from: data)
    }
}
