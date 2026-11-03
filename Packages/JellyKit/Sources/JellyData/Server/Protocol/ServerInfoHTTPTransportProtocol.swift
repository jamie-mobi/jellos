//
//  ServerInfoHTTPTransportProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

protocol ServerInfoHTTPTransportProtocol: Sendable {
    func fetchPublicSystemInfo(server: URL) async throws(ConnectError) -> PublicSystemInfoDTO
}
