//
//  PlaybackRepositoryProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain

public protocol PlaybackRepositoryProtocol: Sendable {
    func playbackSource(itemID: String, startTicks: Int, session: Session) async throws(PlaybackError) -> PlaybackSource
}
