//
//  FeaturedUseCase.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum FeaturedUseCase {

    // MARK: - Constants

    public static let limit = 10

    // MARK: - Featured

    public static func featured(nextUp: [MediaItem], latest: [MediaItem]) -> [MediaItem] {
        var seen = Set<String>()
        var featured: [MediaItem] = []

        for item in nextUp + latest where item.backdropURL != nil {
            let key = item.seriesID ?? item.id
            guard seen.contains(key) == false else {
                continue
            }

            seen.insert(key)
            featured.append(item)
            if featured.count == limit {
                break
            }
        }

        return featured
    }
}
