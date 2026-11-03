//
//  LibraryHTTPTransportTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("LibraryHTTPTransport", .tags(.networking))
struct LibraryHTTPTransportTests {

    // MARK: - Fixtures

    private static let session = Session(
        server: Server(id: "s", name: "Den", version: "1", address: URL(string: "http://demo.local:8096")!),
        user: User(id: "user-a", name: "Alice", hasPassword: true, imageURL: nil),
        accessToken: "token-123"
    )

    // MARK: - Helpers

    private func makeSUT(marker: String) -> LibraryHTTPTransport {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return LibraryHTTPTransport(
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

    // MARK: - Tests

    @Test
    func `fetchUserViews sends GET /UserViews for the user with the token`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: LibraryPayloadFixtures.userViews)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let response = try await makeSUT(marker: marker).fetchUserViews(session: Self.session)

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.url?.absoluteString == "http://demo.local:8096/UserViews?userId=user-a")
        #expect(request.value(forHTTPHeaderField: "Authorization")?.hasSuffix(#"Token="token-123""#) == true)
        #expect(response.items?.count == 3)
    }

    @Test
    func `an expired token maps to .unauthorised`() async {
        let marker = UUID().uuidString
        stub(marker: marker, statusCode: 401, body: "")
        defer { StubURLProtocol.removeStub(marker: marker) }

        await #expect(throws: LibraryError.unauthorised) {
            _ = try await makeSUT(marker: marker).fetchUserViews(session: Self.session)
        }
    }
}
