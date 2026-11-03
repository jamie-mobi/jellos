//
//  PlayerOverlay.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyPlayback
import JellyPresentationCore
import SwiftUI

struct PlayerOverlay: ViewModifier {

    // MARK: - Environment

    @Environment(\.playbackService)
    private var playback

    // MARK: - State

    @State
    private var isShowingError = false

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        content
            .overlay {
                if let player = playback.player {
                    PlayerScreen(player: player) {
                        playback.stop()
                    }
                }
            }
            .onChange(of: playback.state) { _, state in
                isShowingError = state == .failed
            }
            .alert(String(localized: "This item can't be played.", bundle: .module), isPresented: $isShowingError) {
                Button(String(localized: "Close", bundle: .module), role: .cancel) {
                    playback.stop()
                }
            }
    }
}

extension View {
    func playerOverlay() -> some View {
        modifier(PlayerOverlay())
    }
}
#endif
