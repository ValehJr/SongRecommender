//
//  SearchResult.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 07.04.24.
//

import Foundation
enum SearchResult{
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
}
