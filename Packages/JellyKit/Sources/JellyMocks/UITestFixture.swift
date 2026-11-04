//
//  UITestFixture.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if DEBUG
public enum UITestFixture: String, Sendable {
    case connectSuccess = "connect-success"
    case connectUnreachable = "connect-unreachable"
    case users
    case signedIn = "signed-in"
    case signedInNoArt = "signed-in-no-art"
    case signedInResume = "signed-in-resume"

    // MARK: - Launch arguments

    public static let fixtureArgument = "-ui-test-fixture"
    public static let resetArgument = "-ui-test-reset"
    public static let suiteName = "mobi.jamie.jellyOS.uitests"
    public static let keychainService = "mobi.jamie.jellyOS.uitests"

    // MARK: - Constants

    private static let savedPositionTicks = 12_000_000_000

    // MARK: - Init

    public init?(arguments: [String]) {
        guard let index = arguments.firstIndex(of: Self.fixtureArgument),
              arguments.indices.contains(index + 1)
        else {
            return nil
        }

        self.init(rawValue: arguments[index + 1])
    }

    // MARK: - Behaviour

    public var serverBehaviour: MockServerRepository.Behaviour {
        switch self {
        case .connectSuccess,
             .users,
             .signedIn,
             .signedInNoArt,
             .signedInResume:
            .answer(id: "fixture-server", name: "Fixture Server", version: "10.11.0")
        case .connectUnreachable:
            .fail(.network)
        }
    }

    public var seedsServer: Bool {
        switch self {
        case .connectSuccess,
             .connectUnreachable:
            false
        case .users,
             .signedIn,
             .signedInNoArt,
             .signedInResume:
            true
        }
    }

    public var seedsSession: Bool {
        switch self {
        case .connectSuccess,
             .connectUnreachable,
             .users:
            false
        case .signedIn,
             .signedInNoArt,
             .signedInResume:
            true
        }
    }

    public var homeHasArt: Bool {
        self != .signedInNoArt
    }

    public var homeResumeTicks: Int {
        switch self {
        case .connectSuccess,
             .connectUnreachable,
             .users,
             .signedIn,
             .signedInNoArt:
            0
        case .signedInResume:
            Self.savedPositionTicks
        }
    }
}
#endif
