//
//  UserDefaultsSessionStore.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public final class UserDefaultsSessionStore: Sendable {

    // MARK: - Constants

    private static let key = "session"

    // MARK: - Private

    private let suiteName: String?

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    // MARK: - Init

    public init(suiteName: String?) {
        self.suiteName = suiteName
    }

    // MARK: - Store

    public func load(servers: [Server], tokenStore: any TokenStoreProtocol) -> Session? {
        guard let stored = loadStored(),
              let server = servers.first(where: { $0.id == stored.serverID }),
              let token = tokenStore.token(for: stored.userID)
        else {
            return nil
        }

        return stored.toDomain(server: server, accessToken: token)
    }

    public func save(_ session: Session) {
        do {
            try defaults.set(JSONEncoder().encode(StoredSessionDTO(session)), forKey: Self.key)
        } catch {
            AppLog.error("Encoding the session failed: \(error)")
        }
    }

    public func clear() {
        defaults.removeObject(forKey: Self.key)
    }

    // MARK: - Private

    private func loadStored() -> StoredSessionDTO? {
        guard let data = defaults.data(forKey: Self.key) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(StoredSessionDTO.self, from: data)
        } catch {
            AppLog.error("Decoding the saved session failed: \(error)")
            return nil
        }
    }
}
