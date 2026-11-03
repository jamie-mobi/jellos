//
//  StubURLProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Synchronization

final class StubURLProtocol: URLProtocol {

    // MARK: - Types

    typealias Handler = @Sendable (URLRequest) -> (Data?, HTTPURLResponse?, (any Error)?)

    private struct Registry {
        var handlers: [String: Handler] = [:]
        var capturedRequests: [String: URLRequest] = [:]
    }

    // MARK: - Registry

    static let markerHeader = "X-Test-Case"

    private static let registry = Mutex(Registry())

    static func stub(marker: String, handler: @escaping Handler) {
        registry.withLock { $0.handlers[marker] = handler }
    }

    static func removeStub(marker: String) {
        registry.withLock {
            $0.handlers[marker] = nil
            $0.capturedRequests[marker] = nil
        }
    }

    static func capturedRequest(for marker: String) -> URLRequest? {
        registry.withLock { $0.capturedRequests[marker] }
    }

    // MARK: - URLProtocol

    override static func canInit(with request: URLRequest) -> Bool {
        guard let marker = request.value(forHTTPHeaderField: markerHeader) else {
            return false
        }

        return registry.withLock { registry in
            guard registry.handlers[marker] != nil else {
                return false
            }

            registry.capturedRequests[marker] = request
            return true
        }
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let marker = request.value(forHTTPHeaderField: Self.markerHeader),
              let handler = Self.registry.withLock({ $0.handlers[marker] })
        else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        let (data, response, error) = handler(request)

        if let error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        if let response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
