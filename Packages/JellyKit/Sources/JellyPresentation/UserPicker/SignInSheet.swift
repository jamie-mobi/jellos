//
//  SignInSheet.swift
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

struct SignInSheet: View {

    // MARK: - Constants

    private enum Constants {
        static let maxWidth: CGFloat = 380
    }

    // MARK: - Environment

    @Environment(\.signInService)
    private var signIn
    @Environment(\.sessionService)
    private var sessionService

    // MARK: - State

    @State
    private var userName = ""
    @State
    private var password = ""
    @FocusState
    private var focusedField: Field?

    // MARK: - Types

    private enum Field {
        case userName
        case password
    }

    // MARK: - Input

    let server: Server
    let target: SignInTarget
    let onClose: () -> Void

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(String(localized: "Sign In to \(server.name)", bundle: .module))
                .font(.title2.bold())
                .accessibilityIdentifier(AccessibilityID.SignIn.title)

            if case .otherUser = target {
                TextField(String(localized: "User Name", bundle: .module), text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .userName)
                    .accessibilityIdentifier(AccessibilityID.SignIn.userNameField)
            }

            SecureField(String(localized: "Password", bundle: .module), text: $password)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .password)
                .onSubmit(submit)
                .accessibilityIdentifier(AccessibilityID.SignIn.passwordField)

            failureText
            buttons
        }
        .frame(maxWidth: Constants.maxWidth)
        .padding(AppSpacing.regular)
        .onAppear {
            signIn.reset()
            focusedField = targetUserName == nil ? .userName : .password
        }
        .onChange(of: signIn.state) { _, state in
            guard case let .signedIn(session) = state else {
                return
            }

            onClose()
            sessionService.signedIn(session)
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var failureText: some View {
        if case let .failed(failure) = signIn.state {
            Text(message(for: failure))
                .font(.callout)
                .foregroundStyle(.red)
                .accessibilityIdentifier(AccessibilityID.SignIn.error)
        }
    }

    private var buttons: some View {
        HStack {
            Spacer()

            Button(String(localized: "Cancel", bundle: .module), role: .cancel, action: onClose)
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier(AccessibilityID.SignIn.cancelButton)

            Button(action: submit) {
                if signIn.state == .signingIn {
                    Text(String(localized: "Signing In…", bundle: .module))
                } else {
                    Text(String(localized: "Sign In", bundle: .module))
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(signIn.state == .signingIn)
            .accessibilityIdentifier(AccessibilityID.SignIn.signInButton)
        }
    }

    // MARK: - Helpers

    private var targetUserName: String? {
        switch target {
        case let .user(user):
            user.name
        case .otherUser:
            nil
        }
    }

    private func message(for failure: SignInFailure) -> String {
        switch failure {
        case .wrongCredentials:
            String(localized: "The user name or password is not right.", bundle: .module)
        case .unreachable:
            String(localized: "Unable to sign in. Check the connection and try again.", bundle: .module)
        }
    }

    private func submit() {
        let name = targetUserName ?? userName
        Task {
            await signIn.signIn(server: server, userName: name, password: password)
        }
    }
}

#if DEBUG
import JellyMocks

#Preview("Known user") {
    SignInSheet(server: PreviewServers.fixture, target: .user(MockAuthRepository.alice)) {}
}

#Preview("Other user") {
    SignInSheet(server: PreviewServers.longName, target: .otherUser) {}
}
#endif
#endif
