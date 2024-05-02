//
//  AudioViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 09.03.24.
//

import UIKit
import AVFoundation

class LikedViewController: UIViewController, LikedSongsTableViewCellDelegate {

   @IBOutlet weak var songsTableView: UITableView! {
	  didSet {
		 songsTableView.delegate = self
		 songsTableView.dataSource = self
		 let nib = UINib(nibName: "LikedSongsTableViewCell", bundle: nil)
		 songsTableView.register(nib, forCellReuseIdentifier: "LikedSongsTableViewCell")
	  }
   }

   var songs: [Song] = [] {
	  didSet {
		 songsTableView.reloadData()
	  }
   }

   let songFetcher = SongFetcher.shared

   // MARK: Lifecycle Methods

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
	  DispatchQueue.main.async {
		 self.songsTableView.reloadData()
	  }
   }

   override func viewWillAppear(_ animated: Bool) {
	  super.viewWillAppear(animated)
	  // Reload data here
	  self.songsTableView.reloadData()
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

   func saveSongToUserDefaults(song:Song) {
	  do {
		 let encoder = JSONEncoder()
		 let songData = try encoder.encode(song)
		 var songsArray = UserDefaults.standard.array(forKey: "songs") as? [Data] ?? []
		 songsArray.append(songData)
		 UserDefaults.standard.set(songsArray, forKey: "songs")
	  } catch {
		 print("Error encoding song data:", error)
	  }
   }

   func deleteSongFromUserDefaults(song:Song) {
	  var songsArray = UserDefaults.standard.array(forKey: "songs") as? [Data] ?? []
	  songsArray = songsArray.filter { data in
		 do {
			let decoder = JSONDecoder()
			let savedSong = try decoder.decode(Song.self, from: data)
			return savedSong.track_id != song.track_id
		 } catch {
			print("Error decoding song data:", error)
			return true
		 }
	  }

	  UserDefaults.standard.set(songsArray, forKey: "songs")
   }

   func isSongSaved(song:Song) -> Bool {
	  guard let songsData = UserDefaults.standard.array(forKey: "songs") as? [Data] else {
		 return false
	  }
	  for songData in songsData {
		 do {
			let decoder = JSONDecoder()
			let savedSong = try decoder.decode(Song.self, from: songData)
			if savedSong == song {
			   return true
			}
		 } catch {
			print("Error decoding song data:", error)
		 }
	  }
	  return false
   }

}

extension LikedViewController:UITableViewDelegate,UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	  return songs.count
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	  let cell = tableView.dequeueReusableCell(withIdentifier: "LikedSongsTableViewCell", for: indexPath) as! LikedSongsTableViewCell
	  let song = songs[indexPath.row]
	  cell.songName.text = song.track_name
	  cell.artistName.text = song.artist_name
	  if let imageUrl = URL(string: song.image_url) {
		 songFetcher.loadImage(from: imageUrl) { (image) in
			DispatchQueue.main.async{
			   cell.songImageView.image = image
			}
		 }
	  }
	  cell.delegate = self
	  return cell
   }

   func likeButtonDidTap(cell: LikedSongsTableViewCell) {
	  guard let indexPath = songsTableView.indexPath(for: cell) else { return }
	  let song = songs[indexPath.row]
	  if isSongSaved(song: song) {
		 deleteSongFromUserDefaults(song: song)
		 cell.likeButton.setImage(UIImage(named: "heart"), for: .normal)
		 print("delte")
		 self.songsTableView.reloadData()
	  } else {
		 saveSongToUserDefaults(song: song)
		 cell.likeButton.setImage(UIImage(named: "heartFilled"), for: .normal)
		 print("save")
		 self.songsTableView.reloadData()
	  }
   }
}
