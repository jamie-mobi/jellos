//
//  AuthenticationResultDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

struct AuthenticationResultDTO: Decodable {
    let user: UserDTO?
    let accessToken: String?
}
