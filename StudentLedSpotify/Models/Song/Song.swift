//
//  AudioTrack.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 07.04.24.
//

import Foundation
struct Song:Codable {
    let track_name: String
    let artist_name: String
    let track_id: String
    let similarity: Double
    let mp3_url: String?
    let spotify_url: String?
    let image_url: String

  static func == (lhs: Song, rhs: Song) -> Bool {
          return lhs.track_id == rhs.track_id
      }
}
