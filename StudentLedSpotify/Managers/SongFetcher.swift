//
//  SongFetcher.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 15.04.24.
//

import Foundation

struct Song: Decodable {
    let track_name: String
    let artist_name: String
    let track_id: String
    let similarity: Double
    let mp3_url: String?
    let spotify_url: String?
    let image_url: String
}


