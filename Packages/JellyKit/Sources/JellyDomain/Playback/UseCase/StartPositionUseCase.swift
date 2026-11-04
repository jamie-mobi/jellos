//
//  StartPositionUseCase.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 04/11/2026.
//

public enum StartPositionUseCase {

    // MARK: - Offer

    public static func offersChoice(resumeTicks: Int) -> Bool {
        resumeTicks > 0
    }

    // MARK: - Start ticks

    public static func startTicks(for choice: StartChoice, resumeTicks: Int) -> Int {
        switch choice {
        case .resume:
            max(resumeTicks, 0)
        case .startOver:
            0
        }
    }
}
