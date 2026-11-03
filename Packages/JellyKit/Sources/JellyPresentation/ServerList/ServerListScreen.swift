//
//  ServerListScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import JellyPresentationCore
import SwiftUI

struct ServerListScreen: View {

    // MARK: - Input

    let servers: [Server]
    let onSelect: (Server) -> Void
    let onAddServer: () -> Void

    // MARK: - View

    var body: some View {
        List {
            ForEach(Array(servers.enumerated()), id: \.element.id) { index, server in
                Button {
                    onSelect(server)
                } label: {
                    row(server)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(AccessibilityID.ServerList.row(index))
            }
        }
        .accessibilityIdentifier(AccessibilityID.ServerList.list)
        .navigationTitle(String(localized: "Servers", bundle: .module))
        .toolbar {
            Button(String(localized: "Add Server", bundle: .module), systemImage: "plus", action: onAddServer)
                .accessibilityIdentifier(AccessibilityID.ServerList.addButton)
        }
    }

    // MARK: - Row

    private func row(_ server: Server) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall / 2) {
            Text(server.name)
                .font(.headline)
                .lineLimit(1)
            Text(server.address.absoluteString)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
import JellyMocks

#Preview("Servers") {
    NavigationStack {
        ServerListScreen(servers: [PreviewServers.livingRoom, PreviewServers.longName], onSelect: { _ in }, onAddServer: {})
    }
}

#Preview("Empty") {
    NavigationStack {
        ServerListScreen(servers: [], onSelect: { _ in }, onAddServer: {})
    }
}
#endif
#endif
