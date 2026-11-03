//
//  MockAuthRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain

#if DEBUG
public struct MockAuthRepository: AuthRepositoryProtocol {

    // MARK: - Fixtures

    public static let alice = User(id: "fixture-alice", name: "Alice", hasPassword: true, imageURL: nil)
    public static let bob = User(id: "fixture-bob", name: "Bob", hasPassword: false, imageURL: nil)
    public static let password = "secret"

    // MARK: - Input

    private let tokenStore: any TokenStoreProtocol
    private let sessionStore: UserDefaultsSessionStore
    private let serverStore: any ServerStoreProtocol

    // MARK: - Init

    public init(
        tokenStore: any TokenStoreProtocol,
        sessionStore: UserDefaultsSessionStore,
        serverStore: any ServerStoreProtocol
    ) {
        self.tokenStore = tokenStore
        self.sessionStore = sessionStore
        self.serverStore = serverStore
    }

    // MARK: - AuthRepositoryProtocol

    public func publicUsers(server: Server) async throws(SignInError) -> [User] {
        [Self.alice, Self.bob]
    }

    public func signIn(server: Server, userName: String, password: String) async throws(SignInError) -> Session {
        guard let user = [Self.alice, Self.bob].first(where: { $0.name == userName }),
              password == (user.hasPassword ? Self.password : "")
        else {
            throw .unauthorised
        }

        let session = Session(server: server, user: user, accessToken: "fixture-token")
        tokenStore.setToken(session.accessToken, for: user.id)
        sessionStore.save(session)
        return session
    }

    public func restoreSession() async -> Session? {
        sessionStore.load(servers: serverStore.load(), tokenStore: tokenStore)
    }
}
#endif
