//
//  UserTile.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyPresentationCore
import SwiftUI

struct UserTile: View {

    // MARK: - Constants

    private enum Constants {
        static let avatarSize: CGFloat = 96
    }

    // MARK: - Input

    let name: String
    let imageURL: URL?
    let onSelect: () -> Void

    // MARK: - View

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: AppSpacing.xsmall) {
                avatar
                Text(name)
                    .font(.headline)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "\(name), user", bundle: .module))
    }

    // MARK: - Avatar

    private var avatar: some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Image(systemName: "person.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.quaternary)
        }
        .frame(width: Constants.avatarSize, height: Constants.avatarSize)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HStack {
        UserTile(name: "Alice", imageURL: nil) {}
        UserTile(name: "A Very Long User Name Indeed", imageURL: nil) {}
    }
    .padding()
}
#endif
#endif
