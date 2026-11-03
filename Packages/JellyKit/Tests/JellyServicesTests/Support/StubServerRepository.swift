//
//  StubServerRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain

actor StubServerRepository: ServerRepositoryProtocol {

    // MARK: - Types

    private struct CountWaiter {
        let count: Int
        let continuation: CheckedContinuation<Void, Never>
    }

    // MARK: - Configurable results

    private var fetchResult: Result<Server, ConnectError>
    private var saved: [Server]

    // MARK: - Call spies

    private(set) var fetchCallCount = 0
    private(set) var fetchedAddresses: [URL] = []
    private(set) var saveCallCount = 0

    // MARK: - Gate

    private var isGateClosed = false
    private var gateWaiters: [CheckedContinuation<Void, Never>] = []
    private var countWaiters: [CountWaiter] = []

    // MARK: - Init

    init(fetchResult: Result<Server, ConnectError> = .failure(.network), saved: [Server] = []) {
        self.fetchResult = fetchResult
        self.saved = saved
    }

    // MARK: - ServerRepositoryProtocol

    func fetchServer(at address: URL) async throws(ConnectError) -> Server {
        fetchCallCount += 1
        fetchedAddresses.append(address)
        let result = fetchResult
        resumeCountWaiters()

        if isGateClosed {
            await withCheckedContinuation { continuation in
                gateWaiters.append(continuation)
            }
        }

        return try result.get()
    }

    func savedServers() async -> [Server] {
        saved
    }

    func save(_ server: Server) async {
        saveCallCount += 1
        saved.append(server)
    }

    // MARK: - Test configuration

    func closeGate() {
        isGateClosed = true
    }

    func openGate() {
        isGateClosed = false
        let waiters = gateWaiters
        gateWaiters = []
        for waiter in waiters {
            waiter.resume()
        }
    }

    func waitUntilFetchCount(reaches count: Int) async {
        guard fetchCallCount < count else {
            return
        }

        await withCheckedContinuation { continuation in
            countWaiters.append(CountWaiter(count: count, continuation: continuation))
        }
    }

    // MARK: - Private

    private func resumeCountWaiters() {
        let ready = countWaiters.filter { $0.count <= fetchCallCount }
        countWaiters.removeAll { $0.count <= fetchCallCount }
        for waiter in ready {
            waiter.continuation.resume()
        }
    }
}
