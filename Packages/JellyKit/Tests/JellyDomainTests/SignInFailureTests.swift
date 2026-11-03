//
//  SignInFailureTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain
import Testing

@Suite("SignInFailure", .tags(.domain))
struct SignInFailureTests {
    @Test
    func `a rejected user name or password maps to wrong credentials`() {
        #expect(SignInFailure(SignInError.unauthorised) == .wrongCredentials)
    }

    @Test(

        arguments: [SignInError.network, .server, .decoding, .encoding, .forbidden, .notFound, .missingSession]
    )
    func `every other sign-in error maps to unreachable`(error: SignInError) {
        #expect(SignInFailure(error) == .unreachable)
    }
}
