//
//  RootDestinationUseCaseTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import Testing

@Suite("RootDestinationUseCase", .tags(.domain))
struct RootDestinationUseCaseTests {
    @Test(

        arguments: [
            (false, 0, RootDestination.loading),
            (false, 2, RootDestination.loading),
            (true, 0, RootDestination.connect),
            (true, 1, RootDestination.servers)
        ]
    )
    func `shows loading until saved servers load, then Connect with none and the server list with some`(
        hasLoaded: Bool,
        serverCount: Int,
        expected: RootDestination
    ) {
        #expect(RootDestinationUseCase.destination(hasLoaded: hasLoaded, serverCount: serverCount) == expected)
    }
}
