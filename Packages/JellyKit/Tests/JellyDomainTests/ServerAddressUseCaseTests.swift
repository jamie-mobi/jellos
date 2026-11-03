//
//  ServerAddressUseCaseTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain
import Testing

@Suite("ServerAddressUseCase", .tags(.domain))
struct ServerAddressUseCaseTests {

    // MARK: - normalize

    @Test(

        arguments: [
            (" demo.local:8096/ ", "http://demo.local:8096"),
            ("demo.local:8096", "http://demo.local:8096"),
            ("https://Media.Example.com/", "https://media.example.com"),
            ("HTTP://demo.local:8096", "http://demo.local:8096"),
            ("http://demo.local/jellyfin/", "http://demo.local/jellyfin"),
            ("192.168.1.10:8096\n", "http://192.168.1.10:8096")
        ]
    )
    func `turns a typed address into a clean server address`(input: String, expected: String) throws {
        let address = try ServerAddressUseCase.normalize(input)

        #expect(address.absoluteString == expected)
    }

    @Test(

        arguments: ["", "   ", "http://", "https:///", "://8096", "/"]
    )
    func `rejects an address with no host`(input: String) {
        #expect(throws: ConnectError.invalidAddress) {
            try ServerAddressUseCase.normalize(input)
        }
    }

    @Test
    func `rejects a scheme that is not http or https`() {
        #expect(throws: ConnectError.invalidAddress) {
            try ServerAddressUseCase.normalize("ftp://demo.local")
        }
    }

    // MARK: - canConnect

    @Test(

        arguments: [
            ("", false, false),
            ("   ", false, false),
            ("demo.local", false, true),
            ("demo.local", true, false)
        ]
    )
    func `allows Connect only when the address has text and no connect is running`(address: String, isConnecting: Bool, expected: Bool) {
        #expect(ServerAddressUseCase.canConnect(address: address, isConnecting: isConnecting) == expected)
    }
}
