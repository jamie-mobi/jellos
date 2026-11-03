//
//  PlaybackSource.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct PlaybackSource: Equatable, Sendable {

    // MARK: - Stored

    public let url: URL
    public let playSessionID: String?
    public let isTranscoding: Bool

    // MARK: - Init

    public init(url: URL, playSessionID: String?, isTranscoding: Bool) {
        self.url = url
        self.playSessionID = playSessionID
        self.isTranscoding = isTranscoding
    }
}
