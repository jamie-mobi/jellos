//
//  PublicSystemInfoDTOTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("PublicSystemInfoDTO", .tags(.data))
struct PublicSystemInfoDTOTests {
    private static let address = URL(string: "http://demo.local:8096")!

    @Test
    func `toDomain keeps ServerName, Id and Version with the connect address`() throws {
        let dto = try APICoding.makeDecoder().decode(
            PublicSystemInfoDTO.self,
            from: Data(ServerPayloadFixtures.publicSystemInfo.utf8)
        )

        let server = try dto.toDomain(address: Self.address)

        #expect(server == Server(id: "f1a2b3c4d5", name: "Living Room", version: "10.11.0", address: Self.address))
    }

    @Test
    func `a payload with no ServerName is missing server info`() throws {
        let dto = try APICoding.makeDecoder().decode(
            PublicSystemInfoDTO.self,
            from: Data(ServerPayloadFixtures.publicSystemInfoWithoutName.utf8)
        )

        #expect(throws: ConnectError.missingServerInfo) {
            try dto.toDomain(address: Self.address)
        }
    }

    @Test
    func `a payload with no Version keeps an empty version`() throws {
        let dto = PublicSystemInfoDTO(serverName: "Den", version: nil, id: "abc")

        #expect(try dto.toDomain(address: Self.address).version == "")
    }
}
