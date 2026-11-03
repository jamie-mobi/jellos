//
//  AuthHTTPTransportTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("AuthHTTPTransport", .tags(.networking))
struct AuthHTTPTransportTests {

    // MARK: - Fixtures

    private static let server = URL(string: "http://demo.local:8096")!
    private static let identity = ClientIdentity(client: "jellyOS", device: "Mac", deviceID: "device-1", version: "1.0")

    // MARK: - Helpers

    private func makeSUT(marker: String) -> AuthHTTPTransport {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return AuthHTTPTransport(
            urlSession: URLSession(configuration: config),
            identity: Self.identity,
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

    // MARK: - Public users

    @Test
    func `fetchPublicUsers sends GET /Users/Public and decodes the users`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: UserPayloadFixtures.publicUsers)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let users = try await makeSUT(marker: marker).fetchPublicUsers(server: Self.server)

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "http://demo.local:8096/Users/Public")
        #expect(users.map(\.name) == ["Alice", "Bob"])
        #expect(users.first?.hasPassword == true)
    }

    // MARK: - Authenticate

    @Test
    func `authenticate sends POST /Users/AuthenticateByName with Username, Pw and the identity header`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: UserPayloadFixtures.authenticationResult)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let result = try await makeSUT(marker: marker).authenticate(server: Self.server, userName: "Alice", password: "secret")

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "http://demo.local:8096/Users/AuthenticateByName")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(
            request.value(forHTTPHeaderField: "Authorization")
                == #"MediaBrowser Client="jellyOS", Device="Mac", DeviceId="device-1", Version="1.0""#
        )
        let body = try #require(request.httpBody ?? request.bodyStreamData())
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: String])
        #expect(json == ["Username": "Alice", "Pw": "secret"])
        #expect(result.accessToken == "token-123")
    }

    @Test
    func `a rejected password maps to .unauthorised`() async {
        let marker = UUID().uuidString
        stub(marker: marker, statusCode: 401, body: "")
        defer { StubURLProtocol.removeStub(marker: marker) }

        await #expect(throws: SignInError.unauthorised) {
            _ = try await makeSUT(marker: marker).authenticate(server: Self.server, userName: "Alice", password: "bad")
        }
    }
}
