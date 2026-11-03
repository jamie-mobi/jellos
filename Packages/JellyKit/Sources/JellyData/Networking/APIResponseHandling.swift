//
//  APIResponseHandling.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

enum APIResponseHandling {

    // MARK: - Validate

    static func validate<E: APIError>(
        _ response: URLResponse,
        data: Data,
        as errorType: E.Type
    ) throws(E) -> Data {
        guard let http = response as? HTTPURLResponse else {
            throw .network
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw error(forStatus: http.statusCode)
        }

        return data
    }

    // MARK: - Decode

    static func decode<T: Decodable, E: APIError>(
        _ type: T.Type,
        from data: Data,
        using decoder: JSONDecoder = APICoding.makeDecoder(),
        as errorType: E.Type
    ) throws(E) -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            AppLog.error("Decoding \(type) failed: \(error)")
            throw .decoding
        }
    }

    // MARK: - Private

    private static func error<E: APIError>(forStatus code: Int) -> E {
        switch code {
        case 401: .unauthorised
        case 403: .forbidden
        case 404: .notFound
        default: .server
        }
    }
}
