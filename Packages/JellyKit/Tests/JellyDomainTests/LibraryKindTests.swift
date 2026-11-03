//
//  LibraryKindTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import Testing

@Suite("LibraryKind", .tags(.domain))
struct LibraryKindTests {
    @Test(

        arguments: [
            ("movies", LibraryKind.movies),
            ("tvshows", LibraryKind.shows),
            ("music", LibraryKind.music),
            ("boxsets", LibraryKind.collections),
            ("homevideos", LibraryKind.other)
        ]
    )
    func `maps the server collection type to a library kind`(collectionType: String, expected: LibraryKind) {
        #expect(LibraryKind(collectionType: collectionType) == expected)
    }

    @Test
    func `no collection type is other`() {
        #expect(LibraryKind(collectionType: nil) == .other)
    }
}
