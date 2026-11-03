//
//  PlaybackInfoResponseDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

struct PlaybackInfoResponseDTO: Decodable {

    // MARK: - Nested

    struct MediaSourceDTO: Decodable {
        let id: String?
        let transcodingUrl: String?
    }

    // MARK: - Fields

    let mediaSources: [MediaSourceDTO]?
    let playSessionId: String?
    let errorCode: String?
}
