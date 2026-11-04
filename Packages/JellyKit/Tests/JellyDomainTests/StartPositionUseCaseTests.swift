//
//  StartPositionUseCaseTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 04/11/2026.
//

import JellyDomain
import Testing

@Suite("StartPositionUseCase", .tags(.domain))
struct StartPositionUseCaseTests {

    // MARK: - Offer

    @Test(arguments: [1, 12_000_000_000])
    func `an item with a saved position offers Resume or Start Over`(resumeTicks: Int) {
        #expect(StartPositionUseCase.offersChoice(resumeTicks: resumeTicks))
    }

    @Test(arguments: [0, -1])
    func `an item with no saved position plays at once`(resumeTicks: Int) {
        #expect(StartPositionUseCase.offersChoice(resumeTicks: resumeTicks) == false)
    }

    // MARK: - Start ticks

    @Test
    func `Resume starts at the saved position`() {
        #expect(StartPositionUseCase.startTicks(for: .resume, resumeTicks: 12_000_000_000) == 12_000_000_000)
    }

    @Test
    func `Start Over starts at the beginning`() {
        #expect(StartPositionUseCase.startTicks(for: .startOver, resumeTicks: 12_000_000_000) == 0)
    }

    @Test
    func `a negative saved position never starts before the beginning`() {
        #expect(StartPositionUseCase.startTicks(for: .resume, resumeTicks: -5) == 0)
    }
}
