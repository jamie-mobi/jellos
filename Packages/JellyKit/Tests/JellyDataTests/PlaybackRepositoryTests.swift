//
//  PlaybackRepositoryTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("PlaybackRepository", .tags(.networking))
struct PlaybackRepositoryTests {

    // MARK: - Fixtures

    private static let session = Session(
        server: Server(id: "s", name: "Den", version: "1", address: URL(string: "http://demo.local:8096")!),
        user: User(id: "user-a", name: "Alice", hasPassword: true, imageURL: nil),
        accessToken: "token-123"
    )

    // MARK: - Helpers

    private func makeSUT(marker: String) -> PlaybackRepository {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return PlaybackRepository(
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

    private func body(of request: URLRequest) throws -> [String: Any] {
        let data = try #require(request.httpBody ?? request.bodyStreamData())
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    // MARK: - Request

    @Test
    func `posts PlaybackInfo for the user with the HLS HEVC profile and the start ticks`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: PlaybackPayloadFixtures.transcode)
        defer { StubURLProtocol.removeStub(marker: marker) }

        _ = try await makeSUT(marker: marker).playbackSource(itemID: "item-1", startTicks: 600_000_000, session: Self.session)

        let request = try #require(StubURLProtocol.capturedRequest(for: marker))
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "http://demo.local:8096/Items/item-1/PlaybackInfo?userId=user-a")
        #expect(request.value(forHTTPHeaderField: "Authorization")?.hasSuffix(#"Token="token-123""#) == true)
        let json = try body(of: request)
        #expect(json["UserId"] as? String == "user-a")
        #expect(json["StartTimeTicks"] as? Int == 600_000_000)
        let profile = try #require(json["DeviceProfile"] as? [String: Any])
        let transcoding = try #require((profile["TranscodingProfiles"] as? [[String: Any]])?.first)
        #expect(transcoding["Protocol"] as? String == "hls")
        #expect(transcoding["Container"] as? String == "mp4")
        #expect(transcoding["VideoCodec"] as? String == "hevc,h264")
        #expect((transcoding["VideoCodec"] as? String)?.contains("av1") == false)
    }

    // MARK: - Source

    @Test
    func `a TranscodingUrl is used exactly as the server returned it, under the server address`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: PlaybackPayloadFixtures.transcode)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let source = try await makeSUT(marker: marker).playbackSource(itemID: "item-1", startTicks: 0, session: Self.session)

        #expect(source.url.absoluteString
            == "http://demo.local:8096/videos/item-1/master.m3u8?DeviceId=d&MediaSourceId=source-1&VideoCodec=hevc,h264&ApiKey=token-123")
        #expect(source.isTranscoding)
        #expect(source.playSessionID == "play-1")
    }

    @Test
    func `no TranscodingUrl builds the static direct stream URL with the ApiKey`() async throws {
        let marker = UUID().uuidString
        stub(marker: marker, body: PlaybackPayloadFixtures.directStream)
        defer { StubURLProtocol.removeStub(marker: marker) }

        let source = try await makeSUT(marker: marker).playbackSource(itemID: "item-1", startTicks: 0, session: Self.session)

        let components = try #require(URLComponents(url: source.url, resolvingAgainstBaseURL: false))
        #expect(components.path == "/Videos/item-1/stream")
        #expect(components.queryItems?.first { $0.name == "static" }?.value == "true")
        #expect(components.queryItems?.first { $0.name == "mediaSourceId" }?.value == "source-1")
        #expect(components.queryItems?.first { $0.name == "ApiKey" }?.value == "token-123")
        #expect(source.isTranscoding == false)
    }

    @Test
    func `an ErrorCode in the reply fails as refused`() async {
        let marker = UUID().uuidString
        stub(marker: marker, body: PlaybackPayloadFixtures.refused)
        defer { StubURLProtocol.removeStub(marker: marker) }

        await #expect(throws: PlaybackError.refused) {
            _ = try await makeSUT(marker: marker).playbackSource(itemID: "item-1", startTicks: 0, session: Self.session)
        }
    }

    @Test
    func `a reply with no media source fails as no media source`() async {
        let marker = UUID().uuidString
        stub(marker: marker, body: PlaybackPayloadFixtures.noSources)
        defer { StubURLProtocol.removeStub(marker: marker) }

        await #expect(throws: PlaybackError.noMediaSource) {
            _ = try await makeSUT(marker: marker).playbackSource(itemID: "item-1", startTicks: 0, session: Self.session)
        }
    }
}
