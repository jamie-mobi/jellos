//
//  ServerInfoHTTPTransportTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("ServerInfoHTTPTransport", .tags(.networking))
struct ServerInfoHTTPTransportTests {

    // MARK: - Fixtures

    private static let server = URL(string: "http://demo.local:8096")!
    private static let identity = ClientIdentity(client: "jellyOS", device: "Mac", deviceID: "device-1", version: "1.0")

    // MARK: - Helpers

    private func makeSUT(marker: String) -> ServerInfoHTTPTransport {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return ServerInfoHTTPTransport(
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

    // MARK: - Request shape

    @Test
    func `fetchPublicSystemInfo sends GET /System/Info/Public with the client identity`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: ServerPayloadFixtures.publicSystemInfo)
        defer { StubURLProtocol.removeStub(marker: marker) }

        _ = try await makeSUT(marker: marker).fetchPublicSystemInfo(server: Self.server)

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.httpMethod == "GET")
        #expect(request.url?.absoluteString == "http://demo.local:8096/System/Info/Public")
        #expect(
            request.value(forHTTPHeaderField: "Authorization")
                == #"MediaBrowser Client="jellyOS", Device="Mac", DeviceId="device-1", Version="1.0""#
        )
    }

    @Test
    func `a server under a path keeps the path before the endpoint`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: ServerPayloadFixtures.publicSystemInfo)
        defer { StubURLProtocol.removeStub(marker: marker) }

        _ = try await makeSUT(marker: marker).fetchPublicSystemInfo(server: #require(URL(string: "https://host/jellyfin")))

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.url?.absoluteString == "https://host/jellyfin/System/Info/Public")
    }

    // MARK: - Decoding

    @Test
    func `decodes the PascalCase payload`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: ServerPayloadFixtures.publicSystemInfo)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let info = try await makeSUT(marker: marker).fetchPublicSystemInfo(server: Self.server)

        #expect(info.serverName == "Living Room")
        #expect(info.id == "f1a2b3c4d5")
        #expect(info.version == "10.11.0")
    }

    @Test
    func `invalid JSON maps to .decoding`() async {
        let marker = UUID().uuidString
        stub(marker: marker, body: "not json")
        defer { StubURLProtocol.removeStub(marker: marker) }

        await #expect(throws: ConnectError.decoding) {
            _ = try await makeSUT(marker: marker).fetchPublicSystemInfo(server: Self.server)
        }
    }

    // MARK: - Errors

    @Test(

        arguments: [
            (401, ConnectError.unauthorised),
            (403, ConnectError.forbidden),
            (404, ConnectError.notFound),
            (500, ConnectError.server)
        ]
    )
    func `non-2xx status codes map to the matching ConnectError`(statusCode: Int, expected: ConnectError) async {
        let marker = UUID().uuidString
        stub(marker: marker, statusCode: statusCode, body: "")
        defer { StubURLProtocol.removeStub(marker: marker) }

        await #expect(throws: expected) {
            _ = try await makeSUT(marker: marker).fetchPublicSystemInfo(server: Self.server)
        }
    }

    @Test
    func `a server that does not answer maps to .network`() async {
        let marker = UUID().uuidString
        StubURLProtocol.stub(marker: marker) { _ in (nil, nil, URLError(.timedOut)) }
        defer { StubURLProtocol.removeStub(marker: marker) }

        await #expect(throws: ConnectError.network) {
            _ = try await makeSUT(marker: marker).fetchPublicSystemInfo(server: Self.server)
        }
    }
}
