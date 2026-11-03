//
//  UserDefaultsServerStore.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public final class UserDefaultsServerStore: ServerStoreProtocol, Sendable {

    // MARK: - Constants

    private static let key = "servers"

    // MARK: - Private

    private let suiteName: String?

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    // MARK: - Init

    public init(suiteName: String?) {
        self.suiteName = suiteName
    }

    // MARK: - ServerStoreProtocol

    public func load() -> [Server] {
        guard let data = defaults.data(forKey: Self.key) else {
            return []
        }

        do {
            return try JSONDecoder().decode([StoredServerDTO].self, from: data).map { $0.toDomain() }
        } catch {
            AppLog.error("Decoding saved servers failed: \(error)")
            return []
        }
    }

    public func save(_ servers: [Server]) {
        do {
            let data = try JSONEncoder().encode(servers.map(StoredServerDTO.init))
            defaults.set(data, forKey: Self.key)
        } catch {
            AppLog.error("Encoding saved servers failed: \(error)")
        }
    }
}
