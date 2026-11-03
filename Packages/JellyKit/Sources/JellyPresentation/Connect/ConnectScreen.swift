//
//  ConnectScreen.swift
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

struct ConnectScreen: View {

    // MARK: - Constants

    private enum Constants {
        static let maxWidth: CGFloat = 420
    }

    // MARK: - Environment

    @Environment(\.connectService)
    private var service

    // MARK: - State

    @State
    private var address = ""
    @FocusState
    private var isAddressFocused: Bool

    // MARK: - Input

    let onConnected: (Server) -> Void
    var onCancel: (() -> Void)?

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            title
            addressField
            failureText
            buttons
        }
        .frame(maxWidth: Constants.maxWidth)
        .padding(AppSpacing.regular)
        .onAppear {
            service.reset()
            isAddressFocused = true
        }
        .onChange(of: service.state) { _, state in
            guard case let .connected(server) = state else {
                return
            }

            onConnected(server)
        }
    }

    // MARK: - Sections

    private var title: some View {
        Text(String(localized: "Connect to a Server", bundle: .module))
            .font(.largeTitle.bold())
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(AccessibilityID.Connect.title)
    }

    private var addressField: some View {
        TextField(
            String(localized: "Address", bundle: .module),
            text: $address,
            prompt: Text(String(localized: "http://192.168.1.10:8096", bundle: .module))
        )
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .urlKeyboard()
        .focused($isAddressFocused)
        .onSubmit(connect)
        .accessibilityLabel(String(localized: "Server address", bundle: .module))
        .accessibilityIdentifier(AccessibilityID.Connect.addressField)
    }

    @ViewBuilder
    private var failureText: some View {
        if case let .failed(failure) = service.state {
            Text(message(for: failure))
                .font(.callout)
                .foregroundStyle(.red)
                .accessibilityIdentifier(AccessibilityID.Connect.error)
        }
    }

    private var buttons: some View {
        HStack(spacing: AppSpacing.xsmall) {
            Button(String(localized: "Try Demo Content", bundle: .module)) {}
                .disabled(true)
                .help(String(localized: "Demo Content comes in a later update.", bundle: .module))
                .accessibilityIdentifier(AccessibilityID.Connect.demoButton)

            Spacer()

            cancelButton

            Button(action: connect) {
                connectLabel
            }
            .keyboardShortcut(.defaultAction)
            .disabled(isConnectDisabled)
            .accessibilityIdentifier(AccessibilityID.Connect.connectButton)
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        if service.state == .connecting || onCancel != nil {
            Button(String(localized: "Cancel", bundle: .module), role: .cancel, action: cancel)
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier(AccessibilityID.Connect.cancelButton)
        }
    }

    @ViewBuilder
    private var connectLabel: some View {
        if service.state == .connecting {
            HStack(spacing: AppSpacing.xsmall) {
                ProgressView()
                    .controlSize(.small)
                Text(String(localized: "Connecting…", bundle: .module))
            }
        } else {
            Text(String(localized: "Connect", bundle: .module))
        }
    }

    // MARK: - Helpers

    private var isConnectDisabled: Bool {
        ServerAddressUseCase.canConnect(address: address, isConnecting: service.state == .connecting) == false
    }

    private func message(for failure: ConnectFailure) -> String {
        switch failure {
        case .invalidAddress:
            String(localized: "That address is not valid.", bundle: .module)
        case .unreachable:
            String(localized: "Unable to connect to this address. Check it and try again.", bundle: .module)
        }
    }

    private func connect() {
        guard isConnectDisabled == false else {
            return
        }

        Task {
            await service.connect(address: address)
        }
    }

    private func cancel() {
        guard service.state == .connecting else {
            onCancel?()
            return
        }

        service.cancel()
    }
}

// MARK: - URL keyboard

private extension View {
    func urlKeyboard() -> some View {
        #if os(iOS)
        keyboardType(.URL)
            .textInputAutocapitalization(.never)
        #else
        self
        #endif
    }
}

#if DEBUG
import JellyMocks
import JellyServices

#Preview("Answers") {
    ConnectScreen(onConnected: { _ in })
        .environment(
            \.connectService,
            ConnectService(
                repository: MockServerRepository(
                    behaviour: .answer(id: "1", name: "Living Room", version: "10.11.0"),
                    store: MockServerStore()
                )
            )
        )
}

#Preview("Unreachable, as a sheet") {
    ConnectScreen(onConnected: { _ in }, onCancel: {})
        .environment(
            \.connectService,
            ConnectService(repository: MockServerRepository(behaviour: .fail(.network), store: MockServerStore()))
        )
}
#endif
#endif
