//
//  AudioViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 09.04.24.
//

import UIKit
import AVFoundation

class LikedViewController: UIViewController {

  @IBOutlet weak var songsTableView: UITableView! {
    didSet {
      songsTableView.delegate = self
      songsTableView.dataSource = self
      let nib = UINib(nibName: "SongsTableViewCell", bundle: nil)
      songsTableView.register(nib, forCellReuseIdentifier: "SongsTableViewCell")
    }
  }

  var songs: [Song] = [] {
    didSet {
      songsTableView.reloadData()
    }
  }

  let songFetcher = SongFetcher.shared

  override func viewDidLoad() {
    super.viewDidLoad()
    songsTableView.dataSource = self
    songsTableView.delegate = self

    let tabBarItem = UITabBarItem(title: "Liked", image: UIImage(named: "heart"), selectedImage: UIImage(named: "heartFilled"))
    self.tabBarItem = tabBarItem
  }

  override func viewDidAppear(_ animated: Bool) {
    fetchSongsFromUserDefaults()
    let tabBarItem = UITabBarItem(title: "Liked", image: UIImage(named: "heart"), selectedImage: UIImage(named: "heartFilled"))
    self.tabBarItem = tabBarItem
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
      } catch {
          print("Error decoding songs data:", error)
      }
  }
}

extension LikedViewController:UITableViewDelegate,UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return songs.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableViewCell", for: indexPath) as! SongsTableViewCell
    let song = songs[indexPath.row]
    cell.nameLabel.text = song.track_name
    cell.artistLabel.text = song.artist_name
    if let imageUrl = URL(string: song.image_url) {
      songFetcher.loadImage(from: imageUrl) { (image) in
        DispatchQueue.main.async{
          cell.songImage.image = image
        }
      }
    }
    if song.mp3_url != nil {
      cell.spotifyImage.image = nil
    } else {
      cell.spotifyImage.image = UIImage(named: "spotify")
    }
    return cell
  }

}
