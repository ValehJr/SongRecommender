//
//  AudioTrack.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 09.03.24.
//

import Foundation
//Song structure
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
// Playlist structure
struct Playlist: Codable {
   let username: String
   let profile_picture:String
   let playlist: String
   let n_tracks: Int
   let image: String
   let duration: String
   let songs: [Song]
}
