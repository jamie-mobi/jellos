//
//  StubPlaybackRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain

actor StubPlaybackRepository: PlaybackRepositoryProtocol {
    private let result: Result<PlaybackSource, PlaybackError>
    private(set) var requests: [(itemID: String, startTicks: Int)] = []

    init(result: Result<PlaybackSource, PlaybackError>) {
        self.result = result
    }

    func playbackSource(itemID: String, startTicks: Int, session: Session) async throws(PlaybackError) -> PlaybackSource {
        requests.append((itemID, startTicks))
        return try result.get()
    }
}
