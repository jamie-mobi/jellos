//
//  HomeScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import JellyPlayback
import JellyPresentationCore
import JellyServices
import SwiftUI

struct HomeScreen: View {

    // MARK: - Environment

    @Environment(\.homeService)
    private var home
    @Environment(\.playbackService)
    private var playback

    // MARK: - Input

    let session: Session

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.regular) {
                content
            }
        }
        .ignoresSafeArea(edges: .top)
        .accessibilityIdentifier(AccessibilityID.Main.home)
        .navigationTitle(String(localized: "Home", bundle: .module))
        .task(id: session.user.id) {
            await home.start(session: session)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch home.state {
        case .loading:
            ProgressView()
                .padding(AppSpacing.regular)

        case let .loaded(featured):
            if let first = featured.first {
                hero(FeaturedHeroUseCase.hero(for: first), count: featured.count)
            }
        }
    }

    private func hero(_ hero: FeaturedHero, count: Int) -> some View {
        FeaturedHeroView(
            hero: hero,
            position: 1,
            count: count,
            isFavorite: home.isFavorite(itemID: hero.favoriteItemID, default: hero.isFavorite),
            onPlay: { play(hero) },
            onToggleFavorite: { toggleFavorite(hero) }
        )
    }

    // MARK: - Helpers

    private func play(_ hero: FeaturedHero) {
        Task {
            guard let itemID = await home.playableItemID(for: hero, session: session) else {
                return
            }

            await playback.play(itemID: itemID, startTicks: hero.resumeTicks, session: session)
        }
    }

    private func toggleFavorite(_ hero: FeaturedHero) {
        let current = home.isFavorite(itemID: hero.favoriteItemID, default: hero.isFavorite)
        Task {
            await home.toggleFavorite(itemID: hero.favoriteItemID, current: current, session: session)
        }
    }
}
#endif
