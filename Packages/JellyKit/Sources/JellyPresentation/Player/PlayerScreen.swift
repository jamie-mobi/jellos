//
//  PlayerScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import AVKit
import JellyAccessibility
import JellyPresentationCore
import SwiftUI

struct PlayerScreen: View {

    // MARK: - Input

    let player: AVPlayer
    let onClose: () -> Void

    // MARK: - View

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black
                .ignoresSafeArea()

            VideoPlayer(player: player)
                .ignoresSafeArea()
                .accessibilityIdentifier(AccessibilityID.Player.view)

            Button(String(localized: "Close", bundle: .module), systemImage: "xmark", action: onClose)
                .labelStyle(.iconOnly)
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .keyboardShortcut(.cancelAction)
                .padding(AppSpacing.small)
                .accessibilityIdentifier(AccessibilityID.Player.close)
        }
    }
}
#endif
