//
//  FeaturedHeroUseCaseTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import Testing

@Suite("FeaturedHeroUseCase", .tags(.domain))
struct FeaturedHeroUseCaseTests {

    // MARK: - Primary action

    @Test
    func `a movie with no saved position plays`() {
        #expect(FeaturedHeroUseCase.hero(for: MediaItemFixtures.movie("m1")).action == .play)
    }

    @Test
    func `an item with a saved position resumes`() {
        #expect(FeaturedHeroUseCase.hero(for: MediaItemFixtures.movie("m1", resumeTicks: 50)).action == .resume)
        #expect(FeaturedHeroUseCase.hero(for: MediaItemFixtures.episode("e1", seriesID: "s", resumeTicks: 50)).action == .resume)
    }

    @Test
    func `a Next Up episode plays that season and episode`() {
        let hero = FeaturedHeroUseCase.hero(for: MediaItemFixtures.episode("e1", seriesID: "s", season: 2, episode: 3))

        #expect(hero.action == .playEpisode(season: 2, episode: 3))
    }

    @Test
    func `an episode with no season or episode number just plays`() {
        let hero = FeaturedHeroUseCase.hero(for: MediaItemFixtures.episode("e1", seriesID: "s", season: nil, episode: nil))

        #expect(hero.action == .play)
    }

    // MARK: - Identity

    @Test
    func `a hero is identified by the item it features`() {
        #expect(FeaturedHeroUseCase.hero(for: MediaItemFixtures.episode("e1", seriesID: "s1")).id == "e1")
        #expect(FeaturedHeroUseCase.hero(for: MediaItemFixtures.series("s1")).id == "s1")
    }

    // MARK: - Text

    @Test
    func `an episode is shown as its series`() {
        let hero = FeaturedHeroUseCase.hero(for: MediaItemFixtures.episode("e1", seriesID: "s1"))

        #expect(hero.title == "Series s1")
        #expect(hero.kind == .series)
        #expect(hero.favoriteItemID == "s1")
        #expect(hero.playItemID == "e1")
    }

    @Test
    func `the metadata keeps the first two genres and the rating`() {
        let hero = FeaturedHeroUseCase.hero(for: MediaItemFixtures.movie("m1"))

        #expect(hero.kind == .movie)
        #expect(hero.genres == ["Action", "Sci-Fi"])
        #expect(hero.officialRating == "PG-13")
        #expect(hero.playItemID == "m1")
        #expect(hero.resumeTicks == 0)
    }

    @Test
    func `a series from Latest has no item to play until its first episode is found`() {
        let hero = FeaturedHeroUseCase.hero(for: MediaItemFixtures.series("s1"))

        #expect(hero.playItemID == nil)
        #expect(hero.seriesID == "s1")
        #expect(hero.favoriteItemID == "s1")
    }
}
