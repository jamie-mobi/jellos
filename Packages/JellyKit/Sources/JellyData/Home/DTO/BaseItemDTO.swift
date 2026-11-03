//
//  BaseItemDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

struct BaseItemDTO: Decodable {

    // MARK: - Nested

    struct UserDataDTO: Decodable {
        let playbackPositionTicks: Int?
        let isFavorite: Bool?
    }

    // MARK: - Fields

    let id: String?
    let name: String?
    let type: String?
    let overview: String?
    let genres: [String]?
    let officialRating: String?
    let seriesName: String?
    let seriesId: String?
    let parentIndexNumber: Int?
    let indexNumber: Int?
    let userData: UserDataDTO?
    let backdropImageTags: [String]?
    let parentBackdropItemId: String?
    let parentBackdropImageTags: [String]?
    let imageTags: [String: String]?
    let parentLogoItemId: String?
    let parentLogoImageTag: String?
}

// MARK: - Domain mapping

extension BaseItemDTO {
    func toDomain(server: URL) -> MediaItem? {
        guard let id, let name else {
            return nil
        }

        return MediaItem(
            id: id,
            name: name,
            kind: MediaKind(type: type),
            overview: overview,
            genres: genres ?? [],
            officialRating: officialRating,
            seriesID: seriesId,
            seriesName: seriesName,
            seasonNumber: parentIndexNumber,
            episodeNumber: indexNumber,
            resumeTicks: userData?.playbackPositionTicks ?? 0,
            isFavorite: userData?.isFavorite ?? false,
            backdropURL: backdropURL(server: server, id: id),
            logoURL: logoURL(server: server, id: id)
        )
    }

    // MARK: - Private

    private func backdropURL(server: URL, id: String) -> URL? {
        if let tag = backdropImageTags?.first {
            return APICatalogue.itemImage(server: server, itemID: id, type: "Backdrop/0", tag: tag, maxWidth: 1920)
        }
        if let parent = parentBackdropItemId, let tag = parentBackdropImageTags?.first {
            return APICatalogue.itemImage(server: server, itemID: parent, type: "Backdrop/0", tag: tag, maxWidth: 1920)
        }

        return nil
    }

    private func logoURL(server: URL, id: String) -> URL? {
        if let tag = imageTags?["Logo"] ?? imageTags?["logo"] {
            return APICatalogue.itemImage(server: server, itemID: id, type: "Logo", tag: tag, maxWidth: 800)
        }
        if let parent = parentLogoItemId, let tag = parentLogoImageTag {
            return APICatalogue.itemImage(server: server, itemID: parent, type: "Logo", tag: tag, maxWidth: 800)
        }

        return nil
    }
}
