//
//  HTTPBody.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

enum HTTPBody {
    static func encode<T: Encodable, E: APIError>(_ value: T, as errorType: E.Type) throws(E) -> Data {
        do {
            return try APICoding.makeEncoder().encode(value)
        } catch {
            AppLog.error("Encoding \(T.self) failed: \(error)")
            throw .encoding
        }
    }
}
