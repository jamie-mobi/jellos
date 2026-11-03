//
//  FeaturedHeroView.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import JellyPresentationCore
import SwiftUI

struct FeaturedHeroView: View {

    // MARK: - Constants

    private enum Constants {
        static let heightFraction: CGFloat = 0.6
        static let minHeight: CGFloat = 320
        static let infoMaxWidth: CGFloat = 560
        static let logoMaxWidth: CGFloat = 360
        static let logoMaxHeight: CGFloat = 120
        static let badgeCornerRadius: CGFloat = 4
        static let badgePadding: CGFloat = 4
        static let scrimOpacity = 0.85
    }

    // MARK: - Input

    let hero: FeaturedHero
    let position: Int
    let count: Int
    let isFavorite: Bool
    let onPlay: () -> Void
    let onToggleFavorite: () -> Void

    // MARK: - View

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backdrop
            scrim
            info
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical) { length, _ in
            max(length * Constants.heightFraction, Constants.minHeight)
        }
        .clipped()
        .environment(\.colorScheme, .dark)
        .foregroundStyle(.white)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(String(localized: "Featured, \(hero.title), \(position) of \(count)", bundle: .module))
        .accessibilityIdentifier(AccessibilityID.Home.hero)
    }

    // MARK: - Layers

    private var backdrop: some View {
        AsyncImage(url: hero.backdropURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            LinearGradient(colors: [.gray.opacity(0.6), .black], startPoint: .top, endPoint: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityHidden(true)
    }

    private var scrim: some View {
        LinearGradient(colors: [.clear, .black.opacity(Constants.scrimOpacity)], startPoint: .center, endPoint: .bottom)
            .accessibilityHidden(true)
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xsmall) {
            title
            metadata

            if let overview = hero.overview {
                Text(overview)
                    .font(.body)
                    .lineLimit(2)
                    .accessibilityIdentifier(AccessibilityID.Home.heroOverview)
            }

            buttons
        }
        .frame(maxWidth: Constants.infoMaxWidth, alignment: .leading)
        .padding(AppSpacing.regular)
    }

    // MARK: - Info

    @ViewBuilder
    private var title: some View {
        if let logoURL = hero.logoURL {
            AsyncImage(url: logoURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: Constants.logoMaxWidth, maxHeight: Constants.logoMaxHeight, alignment: .leading)
            } placeholder: {
                titleText
            }
            .accessibilityLabel(hero.title)
            .accessibilityIdentifier(AccessibilityID.Home.heroTitle)
        } else {
            titleText
                .accessibilityIdentifier(AccessibilityID.Home.heroTitle)
        }
    }

    private var titleText: some View {
        Text(hero.title)
            .font(.largeTitle.bold())
            .lineLimit(2)
    }

    private var metadata: some View {
        HStack(spacing: AppSpacing.xsmall) {
            Text(metadataLine)
                .font(.subheadline)
                .accessibilityIdentifier(AccessibilityID.Home.heroMetadata)

            if let rating = hero.officialRating {
                Text(rating)
                    .font(.caption.bold())
                    .padding(.horizontal, Constants.badgePadding)
                    .overlay {
                        RoundedRectangle(cornerRadius: Constants.badgeCornerRadius)
                            .stroke(.white.opacity(0.7))
                    }
                    .accessibilityIdentifier(AccessibilityID.Home.heroRating)
            }
        }
    }

    private var buttons: some View {
        HStack(spacing: AppSpacing.xsmall) {
            Button(action: onPlay) {
                Label(primaryLabel, systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .foregroundStyle(.black)
            .accessibilityIdentifier(AccessibilityID.Home.heroPrimaryButton)

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .help(favoriteLabel)
            .accessibilityLabel(favoriteLabel)
            .accessibilityIdentifier(AccessibilityID.Home.heroFavoriteButton)
        }
    }

    // MARK: - Helpers

    private var metadataLine: String {
        ([kindLabel] + hero.genres).joined(separator: " · ")
    }

    private var kindLabel: String {
        switch hero.kind {
        case .movie:
            String(localized: "Movie", bundle: .module)
        case .series,
             .episode:
            String(localized: "Series", bundle: .module)
        case .other:
            String(localized: "Video", bundle: .module)
        }
    }

    private var primaryLabel: String {
        switch hero.action {
        case .play:
            String(localized: "Play", bundle: .module)
        case .resume:
            String(localized: "Resume", bundle: .module)
        case let .playEpisode(season, episode):
            String(localized: "Play S\(season), E\(episode)", bundle: .module)
        }
    }

    private var favoriteLabel: String {
        isFavorite
            ? String(localized: "Remove from Favorites", bundle: .module)
            : String(localized: "Add to Favorites", bundle: .module)
    }
}

#if DEBUG
import JellyMocks

#Preview("Next Up episode") {
    ScrollView {
        FeaturedHeroView(
            hero: FeaturedHeroUseCase.hero(for: MockHomeRepository.nextUp(withArt: true)[0]),
            position: 1,
            count: 10,
            isFavorite: false,
            onPlay: {},
            onToggleFavorite: {}
        )
    }
}

#Preview("Resume, no image, favourite") {
    ScrollView {
        FeaturedHeroView(
            hero: FeaturedHeroUseCase.hero(for: MockHomeRepository.latest(withArt: false)[0]),
            position: 2,
            count: 2,
            isFavorite: true,
            onPlay: {},
            onToggleFavorite: {}
        )
    }
}
#endif
#endif
