//
//  StubAuthRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain

actor StubAuthRepository: AuthRepositoryProtocol {

    // MARK: - Configurable results

    private var usersResult: Result<[User], SignInError>
    private var signInResult: Result<Session, SignInError>
    private var restored: Session?

    // MARK: - Call spies

    private(set) var signInCalls: [(userName: String, password: String)] = []

    // MARK: - Init

    init(
        usersResult: Result<[User], SignInError> = .success([]),
        signInResult: Result<Session, SignInError> = .failure(.network),
        restored: Session? = nil
    ) {
        self.usersResult = usersResult
        self.signInResult = signInResult
        self.restored = restored
    }

    // MARK: - AuthRepositoryProtocol

    func publicUsers(server: Server) async throws(SignInError) -> [User] {
        try usersResult.get()
    }

    func signIn(server: Server, userName: String, password: String) async throws(SignInError) -> Session {
        signInCalls.append((userName, password))
        return try signInResult.get()
    }

    func restoreSession() async -> Session? {
        restored
    }
}
