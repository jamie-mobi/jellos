//
//  SessionServiceTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import JellyServices
import Testing

@Suite("SessionService", .tags(.service))
struct SessionServiceTests {
    @Test
    func `there is no session and nothing restored before restore`() async {
        let sut = await SessionService(repository: StubAuthRepository(restored: SessionFixtures.session))

        #expect(await sut.session == nil)
        #expect(await sut.hasRestored == false)
    }

    @Test
    func `restore brings back the last session`() async {
        let sut = await SessionService(repository: StubAuthRepository(restored: SessionFixtures.session))

        await sut.restore()

        #expect(await sut.session == SessionFixtures.session)
        #expect(await sut.hasRestored)
    }

    @Test
    func `restore with no saved session ends restored and signed out`() async {
        let sut = await SessionService(repository: StubAuthRepository())

        await sut.restore()

        #expect(await sut.session == nil)
        #expect(await sut.hasRestored)
    }

    @Test
    func `signedIn sets the session`() async {
        let sut = await SessionService(repository: StubAuthRepository())

        await sut.signedIn(SessionFixtures.session)

        #expect(await sut.session == SessionFixtures.session)
    }
}
