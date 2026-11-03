//
//  SignInServiceTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import JellyServices
import Testing

@Suite("SignInService", .tags(.service))
struct SignInServiceTests {
    @Test
    func `the state is idle before sign-in`() async {
        let sut = await SignInService(repository: StubAuthRepository())

        #expect(await sut.state == .idle)
    }

    @Test
    func `signIn sends the user name and password and ends signed in`() async {
        let repository = StubAuthRepository(signInResult: .success(SessionFixtures.session))
        let sut = await SignInService(repository: repository)

        await sut.signIn(server: SessionFixtures.server, userName: "Alice", password: "secret")

        #expect(await sut.state == .signedIn(SessionFixtures.session))
        #expect(await repository.signInCalls.map(\.userName) == ["Alice"])
        #expect(await repository.signInCalls.map(\.password) == ["secret"])
    }

    @Test
    func `a wrong password ends in the wrong credentials failure`() async {
        let sut = await SignInService(repository: StubAuthRepository(signInResult: .failure(.unauthorised)))

        await sut.signIn(server: SessionFixtures.server, userName: "Alice", password: "bad")

        #expect(await sut.state == .failed(.wrongCredentials))
    }

    @Test
    func `reset clears a failure`() async {
        let sut = await SignInService(repository: StubAuthRepository(signInResult: .failure(.unauthorised)))
        await sut.signIn(server: SessionFixtures.server, userName: "Alice", password: "bad")

        await sut.reset()

        #expect(await sut.state == .idle)
    }
}
