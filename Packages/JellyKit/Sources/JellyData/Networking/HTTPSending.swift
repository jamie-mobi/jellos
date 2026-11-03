//
//  HTTPSending.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

enum HTTPSending {

    // MARK: - Send

    @concurrent
    static func send<T: Decodable, E: APIError>(
        _ request: URLRequest,
        urlSession: URLSession,
        errorType: E.Type,
        as type: T.Type
    ) async throws(E) -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            logFailure(error, request: request, statusCode: nil)
            throw .network
        }

        do {
            let payload = try APIResponseHandling.validate(response, data: data, as: E.self)
            return try APIResponseHandling.decode(type, from: payload, as: E.self)
        } catch {
            logFailure(error, request: request, statusCode: (response as? HTTPURLResponse)?.statusCode)
            throw error
        }
    }

    // MARK: - Private

    private static func logFailure(_ error: any Error, request: URLRequest, statusCode: Int?) {
        let method = request.httpMethod ?? "GET"
        let path = request.url?.path() ?? "?"
        AppLog.error("\(method) \(path) failed: HTTP \(statusCode?.description ?? "none"): \(error)")
    }
}
