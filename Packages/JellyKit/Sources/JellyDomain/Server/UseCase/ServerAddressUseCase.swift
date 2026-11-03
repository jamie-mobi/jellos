//
//  ServerAddressUseCase.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum ServerAddressUseCase {

    // MARK: - Constants

    private static let schemeSeparator = "://"
    private static let defaultScheme = "http"
    private static let allowedSchemes: Set<String> = ["http", "https"]

    // MARK: - Normalize

    public static func normalize(_ input: String) throws(ConnectError) -> URL {
        let trimmed = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let withScheme = input.contains(schemeSeparator) ? trimmed : defaultScheme + schemeSeparator + trimmed

        guard var components = URLComponents(string: withScheme),
              let scheme = components.scheme?.lowercased(),
              allowedSchemes.contains(scheme),
              let host = components.host?.lowercased(),
              host.isEmpty == false
        else {
            throw .invalidAddress
        }

        components.scheme = scheme
        components.host = host
        components.path = trimmedPath(components.path)

        guard let url = components.url else {
            throw .invalidAddress
        }

        return url
    }

    // MARK: - Connect button

    public static func canConnect(address: String, isConnecting: Bool) -> Bool {
        guard isConnecting == false else {
            return false
        }

        return address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    // MARK: - Private

    private static func trimmedPath(_ path: String) -> String {
        let trimmed = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.isEmpty ? "" : "/" + trimmed
    }
}
