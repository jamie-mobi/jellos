//
//  APIError.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

protocol APIError: Error, Equatable {
    static var network: Self { get }
    static var server: Self { get }
    static var decoding: Self { get }
    static var encoding: Self { get }
    static var unauthorised: Self { get }
    static var forbidden: Self { get }
    static var notFound: Self { get }
}
