//
//  ResumeSheet.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 04/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import JellyPresentationCore
import SwiftUI

struct ResumeSheet: View {

    // MARK: - Constants

    private enum Constants {
        static let maxWidth: CGFloat = 380
    }

    // MARK: - Input

    let title: String
    let onChoose: (StartChoice) -> Void
    let onCancel: () -> Void

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(title)
                .font(.title2.bold())
                .lineLimit(2)

            buttons
        }
        .frame(maxWidth: Constants.maxWidth, alignment: .leading)
        .padding(AppSpacing.regular)
        .presentationDetents([.medium])
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(AccessibilityID.Player.resumeSheet)
    }

    // MARK: - Buttons

    private var buttons: some View {
        HStack {
            Button(String(localized: "Cancel", bundle: .module), role: .cancel, action: onCancel)
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier(AccessibilityID.Player.cancelButton)

            Spacer()

            Button(String(localized: "Start Over", bundle: .module)) {
                onChoose(.startOver)
            }
            .accessibilityIdentifier(AccessibilityID.Player.startOverButton)

            Button(String(localized: "Resume", bundle: .module)) {
                onChoose(.resume)
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(AccessibilityID.Player.resumeButton)
        }
    }
}

#if DEBUG
#Preview("Movie") {
    ResumeSheet(title: "Signal Lost", onChoose: { _ in }, onCancel: {})
}

#Preview("Empty title") {
    ResumeSheet(title: "", onChoose: { _ in }, onCancel: {})
}

#Preview("Long title, no image in this view") {
    ResumeSheet(
        title: "The Extraordinarily Long and Winding Road Back to Driftwood Bay: The Director's Extended Cut",
        onChoose: { _ in },
        onCancel: {}
    )
}
#endif
#endif
