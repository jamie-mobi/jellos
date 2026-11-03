//
//  HomeRepositoryTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("HomeRepository", .tags(.networking))
struct HomeRepositoryTests {

    // MARK: - Fixtures

    private static let session = Session(
        server: Server(id: "s", name: "Den", version: "1", address: URL(string: "http://demo.local:8096")!),
        user: User(id: "user-a", name: "Alice", hasPassword: true, imageURL: nil),
        accessToken: "token-123"
    )

    // MARK: - Helpers

    private func makeSUT(marker: String) -> HomeRepository {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return HomeRepository(
            urlSession: URLSession(configuration: config),
            identity: ClientIdentity(client: "jellyOS", device: "Mac", deviceID: "device-1", version: "1.0"),
            extraHeaders: [StubURLProtocol.markerHeader: marker]
        )
    }

    private func stub(marker: String, statusCode: Int = 200, body: String) {
        StubURLProtocol.stub(marker: marker) { request in
            guard let url = request.url else {
                return (nil, nil, URLError(.badURL))
            }

            return (Data(body.utf8), HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil), nil)
        }
    }

    private func query(_ request: URLRequest) -> [String: String] {
        let items = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems ?? []
        return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
    }

    // MARK: - Next Up

    @Test
    func `nextUp sends GET /Shows/NextUp for the user and maps the series art of an episode`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: ItemPayloadFixtures.nextUp)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let items = try await makeSUT(marker: marker).nextUp(session: Self.session)

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.url?.path() == "/Shows/NextUp")
        #expect(query(request)["userId"] == "user-a")
        #expect(query(request)["fields"] == "Overview,Genres")
        let episode = try #require(items.first)
        #expect(episode.kind == .episode)
        #expect(episode.seriesName == "Driftwood Bay")
        #expect(episode.seasonNumber == 2)
        #expect(episode.episodeNumber == 3)
        #expect(episode.officialRating == "TV-14")
        #expect(episode.backdropURL?.absoluteString
            == "http://demo.local:8096/Items/series-1/Images/Backdrop/0?tag=bd-1&maxWidth=1920")
        #expect(episode.logoURL?.absoluteString == "http://demo.local:8096/Items/series-1/Images/Logo?tag=logo-1&maxWidth=800")
    }

    // MARK: - Latest

    @Test
    func `latest sends GET /Items/Latest for movies and series, maps user data, and drops items with no id`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: ItemPayloadFixtures.latest)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let items = try await makeSUT(marker: marker).latest(session: Self.session)

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.url?.path() == "/Items/Latest")
        #expect(query(request)["includeItemTypes"] == "Movie,Series")
        #expect(items.map(\.id) == ["movie-1", "movie-2"])
        let movie = items[0]
        #expect(movie.resumeTicks == 1200)
        #expect(movie.isFavorite)
        #expect(movie.backdropURL?.absoluteString == "http://demo.local:8096/Items/movie-1/Images/Backdrop/0?tag=bd-m&maxWidth=1920")
        #expect(movie.logoURL?.absoluteString == "http://demo.local:8096/Items/movie-1/Images/Logo?tag=logo-m&maxWidth=800")
        #expect(items[1].backdropURL == nil)
    }

    // MARK: - First episode

    @Test
    func `firstEpisodeID asks for one episode of the series`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: ItemPayloadFixtures.episodes)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let id = try await makeSUT(marker: marker).firstEpisodeID(seriesID: "series-1", session: Self.session)

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.url?.path() == "/Shows/series-1/Episodes")
        #expect(query(request)["limit"] == "1")
        #expect(id == "ep-first")
    }

    // MARK: - Favorites

    @Test(

        arguments: [(true, "POST"), (false, "DELETE")]
    )
    func `setFavorite posts to add and deletes to remove`(isFavorite: Bool, method: String) async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: ItemPayloadFixtures.userData)
        defer { StubURLProtocol.removeStub(marker: marker) }

        try await makeSUT(marker: marker).setFavorite(itemID: "series-1", isFavorite: isFavorite, session: Self.session)

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.httpMethod == method)
        #expect(request.url?.path() == "/UserFavoriteItems/series-1")
        #expect(query(request)["userId"] == "user-a")
    }

    @Test
    func `a failed favorite request throws`() async {
        let marker = UUID().uuidString
        stub(marker: marker, statusCode: 500, body: "")
        defer { StubURLProtocol.removeStub(marker: marker) }

        await #expect(throws: HomeError.server) {
            try await makeSUT(marker: marker).setFavorite(itemID: "x", isFavorite: true, session: Self.session)
        }
    }
}
