//
//  UserPickerService.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import JellyDomain
import Observation

@MainActor
@Observable
public final class UserPickerService {

    // MARK: - State

    public enum State: Equatable, Sendable {
        case loading
        case loaded([User])
        case failed
    }

    public private(set) var state: State = .loading

    // MARK: - Private

    private let repository: any AuthRepositoryProtocol

    // MARK: - Init

    public init(repository: any AuthRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Intent

    public func start(server: Server) async {
        state = .loading
        do {
            let users = try await repository.publicUsers(server: server)
            state = .loaded(users)
        } catch {
            state = .failed
        }
    }
}
