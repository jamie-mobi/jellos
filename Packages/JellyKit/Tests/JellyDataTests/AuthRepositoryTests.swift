//
//  AuthRepositoryTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("AuthRepository", .tags(.data))
struct AuthRepositoryTests {

    // MARK: - Doubles

    private struct StubTransport: AuthHTTPTransportProtocol {
        let result: Result<AuthenticationResultDTO, SignInError>

        func fetchPublicUsers(server: URL) async throws(SignInError) -> [UserDTO] {
            []
        }

        func authenticate(server: URL, userName: String, password: String) async throws(SignInError) -> AuthenticationResultDTO {
            try result.get()
        }
    }

    private final class MemoryTokenStore: TokenStoreProtocol, @unchecked Sendable {
        var tokens: [String: String] = [:]

        func token(for account: String) -> String? {
            tokens[account]
        }

        func setToken(_ token: String, for account: String) {
            tokens[account] = token
        }

        func deleteToken(for account: String) {
            tokens[account] = nil
        }
    }

    // MARK: - Fixtures

    private static let server = Server(id: "s", name: "Den", version: "1", address: URL(string: "http://den.local")!)
    private static let okResult = AuthenticationResultDTO(
        user: UserDTO(id: "user-a", name: "Alice", hasPassword: true, primaryImageTag: nil),
        accessToken: "token-123"
    )

    private func makeSUT(
        result: Result<AuthenticationResultDTO, SignInError> = .success(okResult),
        tokens: MemoryTokenStore = MemoryTokenStore(),
        servers: [Server] = [server]
    ) -> (AuthRepository, MemoryTokenStore) {
        let serverStore = UserDefaultsServerStore(suiteName: "test.\(UUID().uuidString)")
        serverStore.save(servers)
        let sut = AuthRepository(
            transport: StubTransport(result: result),
            tokenStore: tokens,
            sessionStore: UserDefaultsSessionStore(suiteName: "test.\(UUID().uuidString)"),
            serverStore: serverStore
        )
        return (sut, tokens)
    }

    // MARK: - Tests

    @Test
    func `signIn stores the token in the token store and returns the session`() async throws {
        let (sut, tokens) = makeSUT()

        let session = try await sut.signIn(server: Self.server, userName: "Alice", password: "secret")

        #expect(session.accessToken == "token-123")
        #expect(session.user.name == "Alice")
        #expect(tokens.tokens == ["user-a": "token-123"])
    }

    @Test
    func `restoreSession returns the last signed-in session`() async throws {
        let (sut, _) = makeSUT()
        let session = try await sut.signIn(server: Self.server, userName: "Alice", password: "secret")

        #expect(await sut.restoreSession() == session)
    }

    @Test
    func `restoreSession returns nil when the token is gone`() async throws {
        let (sut, tokens) = makeSUT()
        _ = try await sut.signIn(server: Self.server, userName: "Alice", password: "secret")

        tokens.deleteToken(for: "user-a")

        #expect(await sut.restoreSession() == nil)
    }

    @Test
    func `a result with no token fails as missing session`() async {
        let (sut, _) = makeSUT(result: .success(AuthenticationResultDTO(user: Self.okResult.user, accessToken: nil)))

        await #expect(throws: SignInError.missingSession) {
            _ = try await sut.signIn(server: Self.server, userName: "Alice", password: "secret")
        }
    }

    @Test
    func `a rejected password is passed through`() async {
        let (sut, _) = makeSUT(result: .failure(.unauthorised))

        await #expect(throws: SignInError.unauthorised) {
            _ = try await sut.signIn(server: Self.server, userName: "Alice", password: "bad")
        }
    }
}
