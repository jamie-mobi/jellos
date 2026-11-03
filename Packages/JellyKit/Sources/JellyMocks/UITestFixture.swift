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

    // MARK: - Launch arguments

    public static let fixtureArgument = "-ui-test-fixture"
    public static let resetArgument = "-ui-test-reset"
    public static let suiteName = "mobi.jamie.jellyOS.uitests"

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
        case .connectSuccess:
            .answer(id: "fixture-server", name: "Fixture Server", version: "10.11.0")
        case .connectUnreachable:
            .fail(.network)
        }
    }
}
#endif
