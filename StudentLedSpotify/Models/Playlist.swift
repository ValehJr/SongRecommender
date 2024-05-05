//
//  Playlist.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 03.05.24.
//

import Foundation

struct Playlist: Codable {
   let username: String
   let profile_picture:String
   let playlist: String
   let n_tracks: Int
   let image: String
   let duration: String
   let songs: [Song]
}
