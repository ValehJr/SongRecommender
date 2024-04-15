//
//  SearchAlbumResponses.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 07.04.24.
//

import Foundation
struct SearchAlbumsResponse: Codable {
    let items: [Album]
}

struct SearchArtistsResponse: Codable {
    let items: [Artist]
}


struct SearchTracksResponse: Codable {
    let items: [AudioTrack]
}
