//
//  ClientIdentity.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct ClientIdentity: Equatable, Sendable {

    // MARK: - Stored

    public let client: String
    public let device: String
    public let deviceID: String
    public let version: String

    // MARK: - Init

    public init(client: String, device: String, deviceID: String, version: String) {
        self.client = client
        self.device = device
        self.deviceID = deviceID
        self.version = version
    }
}
