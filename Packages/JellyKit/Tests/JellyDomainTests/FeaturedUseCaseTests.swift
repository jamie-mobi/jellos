//
//  FeaturedUseCaseTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import Testing

@Suite("FeaturedUseCase", .tags(.domain))
struct FeaturedUseCaseTests {
    @Test
    func `Next Up comes first, then Latest`() {
        let featured = FeaturedUseCase.featured(
            nextUp: [MediaItemFixtures.episode("e1", seriesID: "s1")],
            latest: [MediaItemFixtures.movie("m1"), MediaItemFixtures.movie("m2")]
        )

        #expect(featured.map(\.id) == ["e1", "m1", "m2"])
    }

    @Test
    func `items with no Backdrop are left out`() {
        let featured = FeaturedUseCase.featured(
            nextUp: [MediaItemFixtures.episode("e1", seriesID: "s1", backdrop: nil)],
            latest: [MediaItemFixtures.movie("m1", backdrop: nil), MediaItemFixtures.movie("m2")]
        )

        #expect(featured.map(\.id) == ["m2"])
    }

    @Test
    func `at most 10 items are featured`() {
        let latest = (1 ... 15).map { MediaItemFixtures.movie("m\($0)") }

        #expect(FeaturedUseCase.featured(nextUp: [], latest: latest).count == 10)
    }

    @Test
    func `a Latest series that is already featured through Next Up is not repeated`() {
        let featured = FeaturedUseCase.featured(
            nextUp: [MediaItemFixtures.episode("e1", seriesID: "s1")],
            latest: [MediaItemFixtures.series("s1"), MediaItemFixtures.movie("m1")]
        )

        #expect(featured.map(\.id) == ["e1", "m1"])
    }

    @Test
    func `nothing to feature gives an empty list`() {
        #expect(FeaturedUseCase.featured(nextUp: [], latest: []).isEmpty)
    }
}
