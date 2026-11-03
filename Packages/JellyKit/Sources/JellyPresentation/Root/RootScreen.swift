//
//  RootScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyDomain
import JellyPresentationCore
import SwiftUI

public struct RootScreen: View {

    // MARK: - Environment

    @Environment(\.serverListService)
    private var serverList

    // MARK: - State

    @State
    private var hasLoaded = false
    @State
    private var isAddingServer = false

    // MARK: - Init

    public init() {}

    // MARK: - View

    public var body: some View {
        content
            .task {
                await serverList.reload()
                hasLoaded = true
            }
            .sheet(isPresented: $isAddingServer) {
                ConnectScreen(onConnected: { _ in serverAdded() }, onCancel: { isAddingServer = false })
            }
            .focusedSceneValue(\.addServer, AddServerAction { isAddingServer = true })
    }

    // MARK: - Destination

    @ViewBuilder
    private var content: some View {
        switch RootDestinationUseCase.destination(hasLoaded: hasLoaded, serverCount: serverList.servers.count) {
        case .loading:
            ProgressView()
        case .connect:
            ConnectScreen(onConnected: { _ in serverAdded() })
        case .servers:
            NavigationStack {
                ServerListScreen(servers: serverList.servers) {
                    isAddingServer = true
                }
            }
        }
    }

    // MARK: - Helpers

    private func serverAdded() {
        isAddingServer = false
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
