//
//  RootDestinationUseCaseTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain
import Testing

@Suite("RootDestinationUseCase", .tags(.domain))
struct RootDestinationUseCaseTests {

    // MARK: - Fixtures

    private static let server = Server(id: "s", name: "Den", version: "1", address: URL(string: "http://den.local")!)
    private static let session = Session(
        server: server,
        user: User(id: "u", name: "Alice", hasPassword: true, imageURL: nil),
        accessToken: "token"
    )

    // MARK: - Tests

    @Test
    func `shows loading until saved servers and the session load`() {
        let destination = RootDestinationUseCase.destination(
            hasLoaded: false,
            servers: [Self.server],
            session: Self.session,
            pickedServer: nil
        )

        #expect(destination == .loading)
    }

    @Test
    func `a signed-in session goes straight to the main screen`() {
        let destination = RootDestinationUseCase.destination(
            hasLoaded: true,
            servers: [Self.server],
            session: Self.session,
            pickedServer: nil
        )

        #expect(destination == .main(Self.session))
    }

    @Test
    func `a picked server shows its user picker`() {
        let destination = RootDestinationUseCase.destination(
            hasLoaded: true,
            servers: [Self.server],
            session: nil,
            pickedServer: Self.server
        )

        #expect(destination == .users(Self.server))
    }

    @Test
    func `no saved servers shows Connect`() {
        let destination = RootDestinationUseCase.destination(hasLoaded: true, servers: [], session: nil, pickedServer: nil)

        #expect(destination == .connect)
    }

    @Test
    func `saved servers and no session show the server list`() {
        let destination = RootDestinationUseCase.destination(
            hasLoaded: true,
            servers: [Self.server],
            session: nil,
            pickedServer: nil
        )

        #expect(destination == .servers)
    }
}
