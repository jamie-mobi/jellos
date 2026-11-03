//
//  HomeRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public final class HomeRepository: HomeRepositoryProtocol, Sendable {

    // MARK: - Private

    private let urlSession: URLSession
    private let identity: ClientIdentity
    private let extraHeaders: [String: String]

    // MARK: - Init

    public init(urlSession: URLSession, identity: ClientIdentity) {
        self.urlSession = urlSession
        self.identity = identity
        extraHeaders = [:]
    }

    init(urlSession: URLSession, identity: ClientIdentity, extraHeaders: [String: String]) {
        self.urlSession = urlSession
        self.identity = identity
        self.extraHeaders = extraHeaders
    }

    // MARK: - HomeRepositoryProtocol

    public func nextUp(session: Session) async throws(HomeError) -> [MediaItem] {
        let url = APICatalogue.nextUp(server: session.server.address, userID: session.user.id)
        let response = try await send(.get, url, session: session, as: ItemsResponseDTO<BaseItemDTO>.self)
        return (response.items ?? []).compactMap { $0.toDomain(server: session.server.address) }
    }

    public func latest(session: Session) async throws(HomeError) -> [MediaItem] {
        let url = APICatalogue.latest(server: session.server.address, userID: session.user.id)
        let items = try await send(.get, url, session: session, as: [BaseItemDTO].self)
        return items.compactMap { $0.toDomain(server: session.server.address) }
    }

    public func firstEpisodeID(seriesID: String, session: Session) async throws(HomeError) -> String? {
        let url = APICatalogue.episodes(server: session.server.address, seriesID: seriesID, userID: session.user.id, limit: 1)
        let response = try await send(.get, url, session: session, as: ItemsResponseDTO<BaseItemDTO>.self)
        return response.items?.first?.id
    }

    public func setFavorite(itemID: String, isFavorite: Bool, session: Session) async throws(HomeError) {
        let url = APICatalogue.favoriteItem(server: session.server.address, itemID: itemID, userID: session.user.id)
        _ = try await send(isFavorite ? .post : .delete, url, session: session, as: UserItemDataDTO.self)
    }

    // MARK: - Private

    private enum Method: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }

    private func send<T: Decodable>(_ method: Method, _ url: URL, session: Session, as type: T.Type) async throws(HomeError) -> T {
        let request = AuthorizedRequest.make(
            url,
            method: method.rawValue,
            session: session,
            identity: identity,
            extraHeaders: extraHeaders
        )
        return try await HTTPSending.send(request, urlSession: urlSession, errorType: HomeError.self, as: type)
    }
}
