//
//  FeaturedHeroUseCase.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum FeaturedHeroUseCase {

    // MARK: - Constants

    private static let genreLimit = 2

    // MARK: - Hero

    public static func hero(for item: MediaItem) -> FeaturedHero {
        let isEpisode = item.kind == .episode

        return FeaturedHero(
            id: item.id,
            title: isEpisode ? item.seriesName ?? item.name : item.name,
            kind: isEpisode ? .series : item.kind,
            genres: Array(item.genres.prefix(genreLimit)),
            officialRating: item.officialRating,
            overview: item.overview,
            logoURL: item.logoURL,
            backdropURL: item.backdropURL,
            action: action(for: item),
            playItemID: item.kind == .series ? nil : item.id,
            seriesID: item.kind == .series ? item.id : item.seriesID,
            favoriteItemID: isEpisode ? item.seriesID ?? item.id : item.id,
            isFavorite: item.isFavorite,
            resumeTicks: item.resumeTicks
        )
    }

    // MARK: - Private

    private static func action(for item: MediaItem) -> PrimaryAction {
        guard item.resumeTicks == 0 else {
            return .resume
        }

        switch (item.kind, item.seasonNumber, item.episodeNumber) {
        case let (.episode, season?, episode?):
            return .playEpisode(season: season, episode: episode)
        case (.episode, _, _),
             (.movie, _, _),
             (.series, _, _),
             (.other, _, _):
            return .play
        }
    }
}
