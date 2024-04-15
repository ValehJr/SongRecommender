//
//  CSVFetcher.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 13.04.24.
//

import Foundation

struct Song {
  var artistName: String
  var trackName: String
  var trackID: String
}

var songs = [Song]()

func parseCSV() {
  guard let filePath = Bundle.main.path(forResource: "artists_songs", ofType: "csv") else {
    return
  }

  var data = ""
  do {
    data = try String(contentsOfFile: filePath)
  } catch {
    print(error)
    return
  }
  var rows = data.components(separatedBy: "\n")
  rows.removeFirst()
  for row in rows {
    let columns = row.components(separatedBy: ",")
    if columns.count >= 3 {
      let artist_name = columns[1]
      let track_name = columns[2]
      let track_id = columns[3]
      let song = Song(artistName: artist_name, trackName: track_name, trackID: track_id)
      songs.append(song)
    }
  }

}
