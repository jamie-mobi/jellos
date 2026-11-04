//
//  PlaybackServiceTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain
import JellyPlayback
import Testing

@Suite("PlaybackService", .tags(.playback))
struct PlaybackServiceTests {

    // MARK: - Fixtures

    private static let session = Session(
        server: Server(id: "s", name: "Den", version: "1", address: URL(string: "http://den.local")!),
        user: User(id: "u", name: "Alice", hasPassword: true, imageURL: nil),
        accessToken: "t"
    )
    private static let source = PlaybackSource(
        url: URL(string: "http://den.local/videos/1/master.m3u8")!,
        playSessionID: "p",
        isTranscoding: true
    )

    // MARK: - Tests

    @Test
    func `the state is idle before play`() async {
        let sut = await PlaybackService(repository: StubPlaybackRepository(result: .success(Self.source)))

        #expect(await sut.state == .idle)
        #expect(await sut.player == nil)
    }

    @Test
    func `play asks for the item at the start position and ends playing with a player`() async {
        let repository = StubPlaybackRepository(result: .success(Self.source))
        let sut = await PlaybackService(repository: repository)

        await sut.play(itemID: "item-1", startTicks: 42, session: Self.session)

        #expect(await sut.state == .playing(Self.source))
        #expect(await sut.player != nil)
        #expect(await repository.requests.map(\.itemID) == ["item-1"])
        #expect(await repository.requests.map(\.startTicks) == [42])
    }

    @Test(arguments: [(StartChoice.resume, 12_000_000_000), (StartChoice.startOver, 0)])
    func `Resume plays from the saved position and Start Over from the beginning`(choice: StartChoice, expected: Int) async {
        let repository = StubPlaybackRepository(result: .success(Self.source))
        let sut = await PlaybackService(repository: repository)

        await sut.play(itemID: "item-1", resumeTicks: 12_000_000_000, choice: choice, session: Self.session)

        #expect(await repository.requests.map(\.startTicks) == [expected])
        #expect(await sut.state == .playing(Self.source))
    }

    @Test
    func `a refused item ends failed with no player`() async {
        let sut = await PlaybackService(repository: StubPlaybackRepository(result: .failure(.refused)))

        await sut.play(itemID: "item-1", startTicks: 0, session: Self.session)

        #expect(await sut.state == .failed)
        #expect(await sut.player == nil)
    }

    @Test
    func `stop returns to idle and drops the player`() async {
        let sut = await PlaybackService(repository: StubPlaybackRepository(result: .success(Self.source)))
        await sut.play(itemID: "item-1", startTicks: 0, session: Self.session)

        await sut.stop()

        #expect(await sut.state == .idle)
        #expect(await sut.player == nil)
    }
}
