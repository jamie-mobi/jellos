//
//  UserPickerScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import JellyPresentationCore
import JellyServices
import SwiftUI

struct UserPickerScreen: View {

    // MARK: - Constants

    private enum Constants {
        static let tileWidth: CGFloat = 140
    }

    // MARK: - Environment

    @Environment(\.userPickerService)
    private var service

    // MARK: - State

    @State
    private var target: SignInTarget?

    // MARK: - Input

    let server: Server
    let onBack: () -> Void

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.regular) {
                Text(String(localized: "Who's Watching?", bundle: .module))
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityIdentifier(AccessibilityID.UserPicker.title)

                content
            }
            .padding(AppSpacing.regular)
        }
        .toolbar {
            Button(String(localized: "Servers", bundle: .module), systemImage: "chevron.backward", action: onBack)
        }
        .task(id: server.id) {
            await service.start(server: server)
        }
        .sheet(item: $target) { target in
            SignInSheet(server: server, target: target) {
                self.target = nil
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch service.state {
        case .loading:
            ProgressView()
        case let .loaded(users):
            grid(users)
        case .failed:
            Text(String(localized: "Unable to load the users of this server.", bundle: .module))
                .foregroundStyle(.secondary)
                .accessibilityIdentifier(AccessibilityID.UserPicker.error)
            grid([])
        }
    }

    private func grid(_ users: [User]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: Constants.tileWidth), spacing: AppSpacing.regular)]) {
            ForEach(Array(users.enumerated()), id: \.element.id) { index, user in
                UserTile(name: user.name, imageURL: user.imageURL) {
                    target = .user(user)
                }
                .accessibilityIdentifier(AccessibilityID.UserPicker.user(index))
            }

            UserTile(name: String(localized: "Other User…", bundle: .module), imageURL: nil) {
                target = .otherUser
            }
            .accessibilityIdentifier(AccessibilityID.UserPicker.otherUser)
        }
    }
}

#if DEBUG
import JellyData
import JellyMocks
import JellyServices

#Preview {
    NavigationStack {
        UserPickerScreen(server: PreviewServers.fixture) {}
            .environment(
                \.userPickerService,
                UserPickerService(repository: MockAuthRepository(
                    tokenStore: MockTokenStore(),
                    sessionStore: UserDefaultsSessionStore(suiteName: "preview"),
                    serverStore: MockServerStore()
                ))
            )
    }
}
#endif
#endif
