//
//  PlaybackRepository.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

public final class PlaybackRepository: PlaybackRepositoryProtocol, Sendable {

    // MARK: - Private

    private let urlSession: URLSession
    private let identity: ClientIdentity
    private let extraHeaders: [String: String]

    // MARK: - Init

    public init(urlSession: URLSession, identity: ClientIdentity) {
        self.urlSession = urlSession
        self.identity = identity
        extraHeaders = [:]
    }

    init(urlSession: URLSession, identity: ClientIdentity, extraHeaders: [String: String]) {
        self.urlSession = urlSession
        self.identity = identity
        self.extraHeaders = extraHeaders
    }

    // MARK: - PlaybackRepositoryProtocol

    public func playbackSource(itemID: String, startTicks: Int, session: Session) async throws(PlaybackError) -> PlaybackSource {
        let body = try HTTPBody.encode(
            PlaybackInfoRequestDTO(
                userId: session.user.id,
                deviceProfile: .appleHLS,
                startTimeTicks: startTicks,
                maxStreamingBitrate: DeviceProfileDTO.maxBitrate
            ),
            as: PlaybackError.self
        )
        let request = AuthorizedRequest.make(
            APICatalogue.playbackInfo(server: session.server.address, itemID: itemID, userID: session.user.id),
            method: "POST",
            session: session,
            identity: identity,
            extraHeaders: extraHeaders,
            body: body
        )
        let response = try await HTTPSending.send(
            request,
            urlSession: urlSession,
            errorType: PlaybackError.self,
            as: PlaybackInfoResponseDTO.self
        )
        return try source(from: response, itemID: itemID, session: session)
    }

    // MARK: - Private

    private func source(
        from response: PlaybackInfoResponseDTO,
        itemID: String,
        session: Session
    ) throws(PlaybackError) -> PlaybackSource {
        guard response.errorCode == nil else {
            throw .refused
        }
        guard let mediaSource = response.mediaSources?.first, let mediaSourceID = mediaSource.id else {
            throw .noMediaSource
        }

        if let transcodingURL = mediaSource.transcodingUrl {
            guard let url = URL(string: session.server.address.absoluteString + transcodingURL) else {
                throw .noMediaSource
            }

            return PlaybackSource(url: url, playSessionID: response.playSessionId, isTranscoding: true)
        }

        let url = APICatalogue.directStream(
            server: session.server.address,
            itemID: itemID,
            mediaSourceID: mediaSourceID,
            token: session.accessToken
        )
        return PlaybackSource(url: url, playSessionID: response.playSessionId, isTranscoding: false)
    }
}
