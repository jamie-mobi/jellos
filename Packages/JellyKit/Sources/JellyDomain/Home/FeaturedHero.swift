//
//  FeaturedHero.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct FeaturedHero: Equatable, Sendable {

    // MARK: - Stored

    public let title: String
    public let kind: MediaKind
    public let genres: [String]
    public let officialRating: String?
    public let overview: String?
    public let logoURL: URL?
    public let backdropURL: URL?
    public let action: PrimaryAction
    public let playItemID: String?
    public let seriesID: String?
    public let favoriteItemID: String
    public let isFavorite: Bool
    public let resumeTicks: Int
}
