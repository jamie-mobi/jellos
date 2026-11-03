//
//  PlaybackService.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AVFoundation
import JellyData
import JellyDomain
import Observation

@MainActor
@Observable
public final class PlaybackService {

    // MARK: - Constants

    private static let ticksPerSecond = 10_000_000.0

    // MARK: - State

    public enum State: Equatable, Sendable {
        case idle
        case loading
        case playing(PlaybackSource)
        case failed
    }

    public private(set) var state: State = .idle
    public private(set) var player: AVPlayer?

    // MARK: - Private

    private let repository: any PlaybackRepositoryProtocol

    // MARK: - Init

    public init(repository: any PlaybackRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Intent

    public func play(itemID: String, startTicks: Int, session: Session) async {
        stop()
        state = .loading

        let source: PlaybackSource
        do {
            source = try await repository.playbackSource(itemID: itemID, startTicks: startTicks, session: session)
        } catch {
            state = .failed
            return
        }

        let player = AVPlayer(url: source.url)
        if source.isTranscoding == false, startTicks > 0 {
            await player.seek(to: CMTime(seconds: Double(startTicks) / Self.ticksPerSecond, preferredTimescale: 600))
        }
        player.play()
        self.player = player
        state = .playing(source)
    }

    public func stop() {
        player?.pause()
        player = nil
        state = .idle
    }
}
