//
//  loadJWT.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/25/21.
//

import Foundation
import JWT

func createJWT(privateKey, privateKeyID, email, scope) {
    
    let authUrl = "https://www.googleapis.com/oauth2/v4/token"
    
    let time = Date().timeIntervalSince1970
    let expires = 3600
    
    let additionalHeaders = [
        "kid": privateKeyID,
        "alg": "RS256",
        "typ": "JWT"
    ]
    
    let payload = [
        "iss": email,          // Issuer claim
        "sub": email,          // Issuer claim
        "aud": auth_url,       // Audience claim
        "iat": issued,         // Issued At claim
        "exp": time + expires, // Expire time
        "scope": scope         // Permissions
    ]
    
    //JWT.encode(payload, additionalHeaders, )
}
