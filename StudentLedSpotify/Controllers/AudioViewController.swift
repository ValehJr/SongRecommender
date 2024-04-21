//
//  AudioViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 09.04.24.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {

  var songs: [Song] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    fetchSongsFromUserDefaults()
    print(songs)
  }

  func fetchSongsFromUserDefaults() {
      guard let songsDataArray = UserDefaults.standard.array(forKey: "songs") as? [Data] else {
          print("No songs data found in UserDefaults.")
          return
      }

      do {
          var songs: [Song] = []
          let decoder = JSONDecoder()
          for songData in songsDataArray {
              let song = try decoder.decode(Song.self, from: songData)
              songs.append(song)
          }

          self.songs = songs
          print("Songs fetched successfully.")
          print("Total Songs: \(songs.count)")
      } catch {
          print("Error decoding songs data:", error)
      }
  }
}
