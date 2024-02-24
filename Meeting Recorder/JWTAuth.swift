//
//  loadJWT.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/25/21.
//

import Foundation
import SwiftyJWT
import SwiftyCrypto

func createJWT() -> [String: Any] {
    
    let scope = "https://www.googleapis.com/auth/cloud-platform"
    let email = "meeting-recorder@meeting-recorder-326219.iam.gserviceaccount.com"
    let privateKeyID = "" // removed
    let privateKey = "" // removed
    
    let authUrl = "https://oauth2.googleapis.com/token"
    
    let time = Date().timeIntervalSince1970
    let expires = 3600
    
    var header = JWTHeader()
    header.keyId = privateKeyID
    header.algorithm = "RS256"
    header.type = "JWT"
    
    var payload = JWTPayload()
    payload.issuer = email
    payload.audience = authUrl
    payload.issueAt = Int(time)
    payload.expiration = Int(time) + expires
    payload.customFields = ["scope": .init(value: scope)]
    
    let algo = JWTAlgorithm.rs256(
        try! RSAKey.init(base64String: privateKey, keyType: .PRIVATE))
    
    let jwt = JWT.init(payload: payload,
             algorithm: algo,
             header: header)
    
    var response: [String: Any] = [
        "access_token": "",
        "expires_in": 0,
        "token_type": ""
    ]
    
    let group = DispatchGroup()
    group.enter()
    
    requestToken(jwt: jwt!.rawString) { isValid in
        response = isValid
        group.leave()
    }

    group.wait()
    return response
}

func requestToken(jwt: String, completion: @escaping ([String: Any]) -> ()) {
    
    let url = URL(string: "https://oauth2.googleapis.com/token")!
    var request = URLRequest(url: url)
    var response: [String: Any] = [
        "access_token": "",
        "expires_in": 0,
        "token_type": ""
    ]
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = [
        "Content-Type": "application/x-www-form-urlencoded".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!,
    ]
    
    let body: [String: String] = [
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": jwt
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    let task = URLSession.shared.dataTask(with: request) { data, response_, error in
        
        guard let data = data,
            let response_ = response_ as? HTTPURLResponse,
            error == nil else { // check for fundamental networking error
            print("error", error ?? "Unknown error")
            completion(response)
            return
        }

        guard (200 ... 299) ~= response_.statusCode else { // check for http errors
            print("statusCode should be 2xx, but is \(response_.statusCode)")
            print("response = " + String(data: data, encoding: .utf8)!)
            completion(response)
            return
        }
        
        if (response_.statusCode == 200) {
            let responseString = String(data: data, encoding: .utf8)
            
            let dict = try? JSONSerialization.jsonObject(with: (responseString?.data(using: .utf8))!) as? [String:Any]
//            print(jwt)
//            print(dict!)
            completion(dict!)
        }
    }
    task.resume()
    
    
}
