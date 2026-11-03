//
//  MockPlaybackRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain

#if DEBUG
public struct MockPlaybackRepository: PlaybackRepositoryProtocol {

    // MARK: - Init

    public init() {}

    // MARK: - PlaybackRepositoryProtocol

    public func playbackSource(itemID: String, startTicks: Int, session: Session) async throws(PlaybackError) -> PlaybackSource {
        PlaybackSource(
            url: session.server.address.appending(path: "videos/\(itemID)/master.m3u8"),
            playSessionID: "fixture-play-session",
            isTranscoding: true
        )
    }
}
#endif
