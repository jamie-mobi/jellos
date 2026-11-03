//
//  UserPickerServiceTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import JellyServices
import Testing

@Suite("UserPickerService", .tags(.service))
struct UserPickerServiceTests {
    @Test
    func `the state is loading before start`() async {
        let sut = await UserPickerService(repository: StubAuthRepository())

        #expect(await sut.state == .loading)
    }

    @Test
    func `start loads the public users of the server`() async {
        let sut = await UserPickerService(repository: StubAuthRepository(usersResult: .success([SessionFixtures.alice])))

        await sut.start(server: SessionFixtures.server)

        #expect(await sut.state == .loaded([SessionFixtures.alice]))
    }

    @Test
    func `no public users is a loaded empty list, so only Other User shows`() async {
        let sut = await UserPickerService(repository: StubAuthRepository(usersResult: .success([])))

        await sut.start(server: SessionFixtures.server)

        #expect(await sut.state == .loaded([]))
    }

    @Test
    func `a failure surfaces as the failed state`() async {
        let sut = await UserPickerService(repository: StubAuthRepository(usersResult: .failure(.network)))

        await sut.start(server: SessionFixtures.server)

        #expect(await sut.state == .failed)
    }
}
