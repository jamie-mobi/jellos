//
//  HomeRepositoryProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain

public protocol HomeRepositoryProtocol: Sendable {
    func nextUp(session: Session) async throws(HomeError) -> [MediaItem]
    func latest(session: Session) async throws(HomeError) -> [MediaItem]
    func firstEpisodeID(seriesID: String, session: Session) async throws(HomeError) -> String?
    func setFavorite(itemID: String, isFavorite: Bool, session: Session) async throws(HomeError)
}
