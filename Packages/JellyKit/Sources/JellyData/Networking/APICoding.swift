//
//  APICoding.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

enum APICoding {

    // MARK: - Key

    private struct Key: CodingKey {
        let stringValue: String
        let intValue: Int?

        init(stringValue: String) {
            self.stringValue = stringValue
            intValue = nil
        }

        init(intValue: Int) {
            stringValue = String(intValue)
            self.intValue = intValue
        }
    }

    // MARK: - Factories

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom { keys in
            Key(stringValue: lowercasingFirst(keys[keys.count - 1].stringValue))
        }
        return decoder
    }

    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .custom { keys in
            Key(stringValue: uppercasingFirst(keys[keys.count - 1].stringValue))
        }
        return encoder
    }

    // MARK: - Private

    private static func lowercasingFirst(_ value: String) -> String {
        value.prefix(1).lowercased() + value.dropFirst()
    }

    private static func uppercasingFirst(_ value: String) -> String {
        value.prefix(1).uppercased() + value.dropFirst()
    }
}
