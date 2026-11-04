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
import JellyPlayback
import JellyServices

public enum AppDependencies {

    // MARK: - Constants

    private static let requestTimeout: TimeInterval = 20
    private static let deviceIDKey = "deviceID"
    private static let keychainService = "mobi.jamie.jellyOS"

    // MARK: - Repositories

    private struct Repositories {
        let server: any ServerRepositoryProtocol
        let auth: any AuthRepositoryProtocol
        let library: any LibraryRepositoryProtocol
        let sidebarStore: any SidebarStoreProtocol
        let playback: any PlaybackRepositoryProtocol
        let home: any HomeRepositoryProtocol
    }

    // MARK: - Graph

    @MainActor
    public static func makeGraph() -> AppGraph {
        let urlSession = URLSession(configuration: makeSessionConfiguration())
        let identity = makeClientIdentity()
        let serverStore = UserDefaultsServerStore(suiteName: nil)

        return makeGraph(repositories: Repositories(
            server: ServerRepository(urlSession: urlSession, identity: identity, store: serverStore),
            auth: AuthRepository(
                urlSession: urlSession,
                identity: identity,
                tokenStore: KeychainTokenStore(service: keychainService),
                sessionStore: UserDefaultsSessionStore(suiteName: nil),
                serverStore: serverStore
            ),
            library: LibraryRepository(urlSession: urlSession, identity: identity),
            sidebarStore: UserDefaultsSidebarStore(suiteName: nil),
            playback: PlaybackRepository(urlSession: urlSession, identity: identity),
            home: HomeRepository(urlSession: urlSession, identity: identity)
        ))
    }

    #if DEBUG
    @MainActor
    public static func makeGraph(arguments: [String]) -> AppGraph {
        guard let fixture = UITestFixture(arguments: arguments) else {
            return makeGraph()
        }

        let serverStore = UserDefaultsServerStore(suiteName: UITestFixture.suiteName)
        let sessionStore = UserDefaultsSessionStore(suiteName: UITestFixture.suiteName)
        let tokenStore = KeychainTokenStore(service: UITestFixture.keychainService)

        if arguments.contains(UITestFixture.resetArgument) {
            reset(fixture: fixture, serverStore: serverStore, sessionStore: sessionStore, tokenStore: tokenStore)
        }

        return makeGraph(repositories: Repositories(
            server: MockServerRepository(behaviour: fixture.serverBehaviour, store: serverStore),
            auth: MockAuthRepository(tokenStore: tokenStore, sessionStore: sessionStore, serverStore: serverStore),
            library: MockLibraryRepository(),
            sidebarStore: UserDefaultsSidebarStore(suiteName: UITestFixture.suiteName),
            playback: MockPlaybackRepository(),
            home: MockHomeRepository(withArt: fixture.homeHasArt, nextUpResumeTicks: fixture.homeResumeTicks)
        ))
    }

    private static func reset(
        fixture: UITestFixture,
        serverStore: UserDefaultsServerStore,
        sessionStore: UserDefaultsSessionStore,
        tokenStore: KeychainTokenStore
    ) {
        UserDefaults(suiteName: UITestFixture.suiteName)?.removePersistentDomain(forName: UITestFixture.suiteName)
        tokenStore.deleteToken(for: MockAuthRepository.alice.id)
        tokenStore.deleteToken(for: MockAuthRepository.bob.id)

        if fixture.seedsServer {
            serverStore.save([PreviewServers.fixture])
        }
        if fixture.seedsSession {
            let session = Session(server: PreviewServers.fixture, user: MockAuthRepository.alice, accessToken: "fixture-token")
            tokenStore.setToken(session.accessToken, for: session.user.id)
            sessionStore.save(session)
        }
    }
    #endif

    // MARK: - Session configuration

    static func makeSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = requestTimeout
        return configuration
    }

    // MARK: - Private

    @MainActor
    private static func makeGraph(repositories: Repositories) -> AppGraph {
        AppGraph(
            connectService: ConnectService(repository: repositories.server),
            serverListService: ServerListService(repository: repositories.server),
            sessionService: SessionService(repository: repositories.auth),
            userPickerService: UserPickerService(repository: repositories.auth),
            signInService: SignInService(repository: repositories.auth),
            sidebarService: SidebarService(repository: repositories.library, store: repositories.sidebarStore),
            playbackService: PlaybackService(repository: repositories.playback),
            homeService: HomeService(repository: repositories.home)
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
