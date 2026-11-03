//
//  MockTokenStore.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyData
import Synchronization

#if DEBUG
public final class MockTokenStore: TokenStoreProtocol, Sendable {

    // MARK: - Private

    private let tokens = Mutex<[String: String]>([:])

    // MARK: - Init

    public init() {}

    // MARK: - TokenStoreProtocol

    public func token(for account: String) -> String? {
        tokens.withLock { $0[account] }
    }

    public func setToken(_ token: String, for account: String) {
        tokens.withLock { $0[account] = token }
    }

    public func deleteToken(for account: String) {
        tokens.withLock { $0[account] = nil }
    }
}
#endif
