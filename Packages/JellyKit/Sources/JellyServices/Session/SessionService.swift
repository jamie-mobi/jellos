//
//  SessionService.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Observation

@MainActor
@Observable
public final class SessionService {

    // MARK: - State

    public private(set) var session: Session?
    public private(set) var hasRestored = false

    // MARK: - Private

    private let repository: any AuthRepositoryProtocol

    // MARK: - Init

    public init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Intent

    public func restore() async {
        session = await repository.restoreSession()
        hasRestored = true
    }

    public func signedIn(_ session: Session) {
        self.session = session
    }
}
