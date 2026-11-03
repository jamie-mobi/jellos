//
//  ConnectServiceTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain
import JellyServices
import Testing

@Suite("ConnectService", .tags(.service))
struct ConnectServiceTests {

    // MARK: - Fixtures

    private static let server = Server(
        id: "abc",
        name: "Den",
        version: "10.11.0",
        address: URL(string: "http://demo.local:8096")!
    )

    // MARK: - Tests

    @Test
    func `the state is idle before any connect`() async {
        let sut = await ConnectService(repository: StubServerRepository())

        #expect(await sut.state == .idle)
    }

    @Test
    func `connect normalizes the address, fetches the server and saves it`() async throws {
        let repository = StubServerRepository(fetchResult: .success(Self.server))
        let sut = await ConnectService(repository: repository)

        await sut.connect(address: " demo.local:8096/ ")

        #expect(await sut.state == .connected(Self.server))
        #expect(try await repository.fetchedAddresses == [#require(URL(string: "http://demo.local:8096"))])
        #expect(await repository.savedServers() == [Self.server])
    }

    @Test
    func `an address with no host fails as invalid and never calls the server`() async {
        let repository = StubServerRepository(fetchResult: .success(Self.server))
        let sut = await ConnectService(repository: repository)

        await sut.connect(address: "http://")

        #expect(await sut.state == .failed(.invalidAddress))
        #expect(await repository.fetchCallCount == 0)
    }

    @Test
    func `a server that does not answer fails as unreachable and saves nothing`() async {
        let repository = StubServerRepository(fetchResult: .failure(.network))
        let sut = await ConnectService(repository: repository)

        await sut.connect(address: "demo.local:8096")

        #expect(await sut.state == .failed(.unreachable))
        #expect(await repository.saveCallCount == 0)
    }

    @Test
    func `the state is connecting while the server has not answered`() async {
        let repository = StubServerRepository(fetchResult: .success(Self.server))
        let sut = await ConnectService(repository: repository)
        await repository.closeGate()

        let task = Task { await sut.connect(address: "demo.local:8096") }
        await repository.waitUntilFetchCount(reaches: 1)

        #expect(await sut.state == .connecting)

        await repository.openGate()
        await task.value
    }

    @Test
    func `cancel returns to idle and a late answer is ignored`() async {
        let repository = StubServerRepository(fetchResult: .success(Self.server))
        let sut = await ConnectService(repository: repository)
        await repository.closeGate()

        let task = Task { await sut.connect(address: "demo.local:8096") }
        await repository.waitUntilFetchCount(reaches: 1)
        await sut.cancel()
        await repository.openGate()
        await task.value

        #expect(await sut.state == .idle)
        #expect(await repository.saveCallCount == 0)
    }

    @Test
    func `a new connect after a failure clears the failure`() async {
        let repository = StubServerRepository(fetchResult: .success(Self.server))
        let sut = await ConnectService(repository: repository)

        await sut.connect(address: "http://")
        await sut.connect(address: "demo.local:8096")

        #expect(await sut.state == .connected(Self.server))
    }

    @Test
    func `reset returns a connected service to idle`() async {
        let sut = await ConnectService(repository: StubServerRepository(fetchResult: .success(Self.server)))
        await sut.connect(address: "demo.local:8096")

        await sut.reset()

        #expect(await sut.state == .idle)
    }
}
