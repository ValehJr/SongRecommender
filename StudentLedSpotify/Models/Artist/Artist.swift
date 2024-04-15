//
//  Artist.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 07.04.24.
//

import Foundation
struct Artist: Codable {
    let id: String
    let name:String
    let type:String
    let external_urls: [String:String]
    let images: [APIImage]?
}
