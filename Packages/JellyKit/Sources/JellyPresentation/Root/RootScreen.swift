//
//  RootScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyDomain
import JellyPresentationCore
import JellyServices
import SwiftUI

public struct RootScreen: View {

    // MARK: - Environment

    @Environment(\.serverListService)
    private var serverList
    @Environment(\.sessionService)
    private var sessionService

    // MARK: - State

    @State
    private var hasLoaded = false
    @State
    private var pickedServer: Server?
    @State
    private var isAddingServer = false

    // MARK: - Init

    public init() {}

    // MARK: - View

    public var body: some View {
        content
            .task {
                await serverList.reload()
                await sessionService.restore()
                hasLoaded = true
            }
            .sheet(isPresented: $isAddingServer) {
                ConnectScreen(onConnected: serverAdded, onCancel: { isAddingServer = false })
            }
            .focusedSceneValue(\.addServer, AddServerAction { isAddingServer = true })
    }

    // MARK: - Destination

    @ViewBuilder
    private var content: some View {
        switch RootDestinationUseCase.destination(
            hasLoaded: hasLoaded,
            servers: serverList.servers,
            session: sessionService.session,
            pickedServer: pickedServer
        ) {
        case .loading:
            ProgressView()

        case .connect:
            ConnectScreen(onConnected: serverAdded)

        case .servers:
            NavigationStack {
                ServerListScreen(
                    servers: serverList.servers,
                    onSelect: { pickedServer = $0 },
                    onAddServer: { isAddingServer = true }
                )
            }

        case let .users(server):
            NavigationStack {
                UserPickerScreen(server: server) {
                    pickedServer = nil
                }
            }

        case let .main(session):
            MainScreen(session: session)
        }
    }

    // MARK: - Helpers

    private func serverAdded(_ server: Server) {
        isAddingServer = false
        pickedServer = server
        Task {
            await serverList.reload()
        }
    }
}

#if DEBUG
import JellyMocks
import JellyServices

#Preview("No servers") {
    RootScreen()
        .environment(
            \.serverListService,
            ServerListService(repository: MockServerRepository(behaviour: .fail(.network), store: MockServerStore()))
        )
}

#Preview("Saved servers") {
    RootScreen()
        .environment(
            \.serverListService,
            ServerListService(
                repository: MockServerRepository(
                    behaviour: .fail(.network),
                    store: MockServerStore(servers: [PreviewServers.livingRoom, PreviewServers.longName])
                )
            )
        )
}
#endif
#endif
