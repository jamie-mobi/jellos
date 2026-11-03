//
//  SignInTarget.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyDomain

enum SignInTarget: Identifiable {
    case user(User)
    case otherUser

    // MARK: - Identifiable

    var id: String {
        switch self {
        case let .user(user):
            user.id
        case .otherUser:
            "other-user"
        }
    }
}
#endif
