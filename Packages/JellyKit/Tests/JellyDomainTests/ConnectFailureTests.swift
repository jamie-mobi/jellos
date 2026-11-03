//
//  ConnectFailureTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import Testing

@Suite("ConnectFailure", .tags(.domain))
struct ConnectFailureTests {
    @Test
    func `an invalid address maps to the invalid address failure`() {
        #expect(ConnectFailure(ConnectError.invalidAddress) == .invalidAddress)
    }

    @Test(

        arguments: [
            ConnectError.network,
            .server,
            .decoding,
            .encoding,
            .unauthorised,
            .forbidden,
            .notFound,
            .missingServerInfo
        ]
    )
    func `every other connect error maps to the unreachable failure`(error: ConnectError) {
        #expect(ConnectFailure(error) == .unreachable)
    }
}
