//
//  ItemsResponseDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

struct ItemsResponseDTO<Item: Decodable>: Decodable {
    let items: [Item]?
}
