//
//  AppDependencies.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyData
import JellyDomain
import JellyMocks
import JellyServices

public enum AppDependencies {

    // MARK: - Constants

    private static let requestTimeout: TimeInterval = 20
    private static let deviceIDKey = "deviceID"

    // MARK: - Graph

    @MainActor
    public static func makeGraph() -> AppGraph {
        makeGraph(repository: makeServerRepository())
    }

    #if DEBUG
    @MainActor
    public static func makeGraph(arguments: [String]) -> AppGraph {
        guard let fixture = UITestFixture(arguments: arguments) else {
            return makeGraph()
        }

        if arguments.contains(UITestFixture.resetArgument) {
            UserDefaults(suiteName: UITestFixture.suiteName)?.removePersistentDomain(forName: UITestFixture.suiteName)
        }

        let store = UserDefaultsServerStore(suiteName: UITestFixture.suiteName)
        return makeGraph(repository: MockServerRepository(behaviour: fixture.serverBehaviour, store: store))
    }
    #endif

    // MARK: - Private

    @MainActor
    private static func makeGraph(repository: any ServerRepositoryProtocol) -> AppGraph {
        AppGraph(
            connectService: ConnectService(repository: repository),
            serverListService: ServerListService(repository: repository)
        )
    }

    private static func makeServerRepository() -> any ServerRepositoryProtocol {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestTimeout

        return ServerRepository(
            urlSession: URLSession(configuration: configuration),
            identity: makeClientIdentity(),
            store: UserDefaultsServerStore(suiteName: nil)
        )
    }

    private static func makeClientIdentity() -> ClientIdentity {
        ClientIdentity(
            client: "jellyOS",
            device: deviceName,
            deviceID: deviceID(),
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1"
        )
    }

    private static func deviceID() -> String {
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: deviceIDKey) {
            return existing
        }

        let created = UUID().uuidString
        defaults.set(created, forKey: deviceIDKey)
        return created
    }

    private static var deviceName: String {
        #if os(macOS)
        "Mac"
        #elseif os(tvOS)
        "Apple TV"
        #else
        "iOS"
        #endif
    }
}
