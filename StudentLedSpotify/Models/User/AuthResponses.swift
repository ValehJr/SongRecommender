//
//  AuthResponses.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 07.04.24.
//

import Foundation

struct AuthResponse: Codable{
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
