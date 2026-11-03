//
//  HomeServiceTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import JellyServices
import Testing

@Suite("HomeService", .tags(.service))
struct HomeServiceTests {
    @Test
    func `the state is loading before start`() async {
        let sut = await HomeService(repository: StubHomeRepository())

        #expect(await sut.state == .loading)
    }

    @Test
    func `start features Next Up then Latest items that have a Backdrop`() async {
        let repository = StubHomeRepository(
            nextUp: .success([MediaItemFixtures.movie("a")]),
            latest: .success([MediaItemFixtures.movie("b"), MediaItemFixtures.movie("c", backdrop: nil)])
        )
        let sut = await HomeService(repository: repository)

        await sut.start(session: SessionFixtures.session)

        #expect(await sut.state == .loaded(featured: [MediaItemFixtures.movie("a"), MediaItemFixtures.movie("b")]))
    }

    @Test
    func `a failed Next Up still features Latest`() async {
        let repository = StubHomeRepository(nextUp: .failure(.network), latest: .success([MediaItemFixtures.movie("b")]))
        let sut = await HomeService(repository: repository)

        await sut.start(session: SessionFixtures.session)

        #expect(await sut.state == .loaded(featured: [MediaItemFixtures.movie("b")]))
    }

    @Test
    func `toggleFavorite changes at once and sends the request`() async {
        let repository = StubHomeRepository()
        let sut = await HomeService(repository: repository)

        await sut.toggleFavorite(itemID: "s1", current: false, session: SessionFixtures.session)

        #expect(await sut.isFavorite(itemID: "s1", default: false))
        #expect(await repository.favoriteCalls.map(\.isFavorite) == [true])
    }

    @Test
    func `a failed favorite request goes back to the old state`() async {
        let sut = await HomeService(repository: StubHomeRepository(favorite: .failure(.network)))

        await sut.toggleFavorite(itemID: "s1", current: true, session: SessionFixtures.session)

        #expect(await sut.isFavorite(itemID: "s1", default: true))
    }

    @Test
    func `a series plays its first episode, anything else plays itself`() async {
        let sut = await HomeService(repository: StubHomeRepository(firstEpisode: .success("ep-first")))
        let seriesHero = FeaturedHeroUseCase.hero(for: MediaItemFixtures.series("s1"))
        let movieHero = FeaturedHeroUseCase.hero(for: MediaItemFixtures.movie("m1"))

        #expect(await sut.playableItemID(for: seriesHero, session: SessionFixtures.session) == "ep-first")
        #expect(await sut.playableItemID(for: movieHero, session: SessionFixtures.session) == "m1")
    }
}
