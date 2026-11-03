//
//  PlaybackInfoRequestDTO.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

struct PlaybackInfoRequestDTO: Encodable {
    let userId: String
    let deviceProfile: DeviceProfileDTO
    let startTimeTicks: Int
    let maxStreamingBitrate: Int
}
