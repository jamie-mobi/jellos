//
//  ConnectService.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain
import Observation

@MainActor
@Observable
public final class ConnectService {

    // MARK: - State

    public enum State: Equatable, Sendable {
        case idle
        case connecting
        case failed(ConnectFailure)
        case connected(Server)
    }

    public var state: State {
        switch (isConnecting, failure, connectedServer) {
        case (true, _, _):
            .connecting
        case (false, let failure?, _):
            .failed(failure)
        case (false, nil, let server?):
            .connected(server)
        case (false, nil, nil):
            .idle
        }
    }

    // MARK: - Private

    private let repository: any ServerRepositoryProtocol

    private var isConnecting = false
    private var failure: ConnectFailure?
    private var connectedServer: Server?
    private var connectTask: Task<Void, Never>?

    // MARK: - Init

    public init(repository: any ServerRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Intent

    public func connect(address: String) async {
        connectTask?.cancel()
        connectedServer = nil

        let url: URL
        do {
            url = try ServerAddressUseCase.normalize(address)
        } catch {
            failure = ConnectFailure(error)
            isConnecting = false
            return
        }

        failure = nil
        isConnecting = true
        let task = Task { [weak self] in
            guard let self else {
                return
            }

            await performConnect(to: url)
        }
        connectTask = task
        await task.value
    }

    public func cancel() {
        connectTask?.cancel()
        connectTask = nil
        isConnecting = false
        failure = nil
    }

    public func reset() {
        cancel()
        connectedServer = nil
    }

    // MARK: - Private

    private func performConnect(to url: URL) async {
        let server: Server
        do {
            server = try await repository.fetchServer(at: url)
        } catch {
            guard Task.isCancelled == false else {
                return
            }

            failure = ConnectFailure(error)
            isConnecting = false
            return
        }

        guard Task.isCancelled == false else {
            return
        }

        await repository.save(server)
        guard Task.isCancelled == false else {
            return
        }

        connectedServer = server
        isConnecting = false
    }
}
