//
//  AuthRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public final class AuthRepository: AuthRepositoryProtocol, Sendable {

    // MARK: - Private

    private let transport: any AuthHTTPTransportProtocol
    private let tokenStore: any TokenStoreProtocol
    private let sessionStore: UserDefaultsSessionStore
    private let serverStore: any ServerStoreProtocol

    // MARK: - Init

    init(
        transport: any AuthHTTPTransportProtocol,
        tokenStore: any TokenStoreProtocol,
        sessionStore: UserDefaultsSessionStore,
        serverStore: any ServerStoreProtocol
    ) {
        self.transport = transport
        self.tokenStore = tokenStore
        self.sessionStore = sessionStore
        self.serverStore = serverStore
    }

    public convenience init(
        urlSession: URLSession,
        identity: ClientIdentity,
        tokenStore: any TokenStoreProtocol,
        sessionStore: UserDefaultsSessionStore,
        serverStore: any ServerStoreProtocol
    ) {
        self.init(
            transport: AuthHTTPTransport(urlSession: urlSession, identity: identity),
            tokenStore: tokenStore,
            sessionStore: sessionStore,
            serverStore: serverStore
        )
    }

    // MARK: - AuthRepositoryProtocol

    public func publicUsers(server: Server) async throws(SignInError) -> [User] {
        let users = try await transport.fetchPublicUsers(server: server.address)
        return users.compactMap { try? $0.toDomain(server: server.address) }
    }

    public func signIn(server: Server, userName: String, password: String) async throws(SignInError) -> Session {
        let result = try await transport.authenticate(server: server.address, userName: userName, password: password)
        guard let userDTO = result.user, let token = result.accessToken else {
            throw .missingSession
        }

        let session = try Session(server: server, user: userDTO.toDomain(server: server.address), accessToken: token)
        tokenStore.setToken(token, for: session.user.id)
        sessionStore.save(session)
        return session
    }

    public func restoreSession() async -> Session? {
        sessionStore.load(servers: serverStore.load(), tokenStore: tokenStore)
    }
}
