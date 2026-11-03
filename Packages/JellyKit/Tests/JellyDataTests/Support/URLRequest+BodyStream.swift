//
//  URLRequest+BodyStream.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

extension URLRequest {
    func bodyStreamData() -> Data? {
        guard let stream = httpBodyStream else {
            return nil
        }

        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else {
                break
            }

            data.append(buffer, count: count)
        }
        return data
    }
}
