//
//  SignInService.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Observation

@MainActor
@Observable
public final class SignInService {

    // MARK: - State

    public enum State: Equatable, Sendable {
        case idle
        case signingIn
        case failed(SignInFailure)
        case signedIn(Session)
    }

    public private(set) var state: State = .idle

    // MARK: - Private

    private let repository: any AuthRepositoryProtocol

    // MARK: - Init

    public init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Intent

    public func signIn(server: Server, userName: String, password: String) async {
        state = .signingIn
        do {
            let session = try await repository.signIn(server: server, userName: userName, password: password)
            state = .signedIn(session)
        } catch {
            state = .failed(SignInFailure(error))
        }
    }

    public func reset() {
        state = .idle
    }
}
