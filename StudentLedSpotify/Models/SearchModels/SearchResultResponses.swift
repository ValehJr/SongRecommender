//
//  SearchResultResponses.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 07.04.24.
//

import Foundation

struct SearchResultResponse: Codable {
    let albums: SearchAlbumsResponse
    let artists: SearchArtistsResponse
    let tracks: SearchTracksResponse
}
