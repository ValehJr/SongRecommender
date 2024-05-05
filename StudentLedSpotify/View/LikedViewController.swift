//
//  AudioViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 09.03.24.
//

import UIKit

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
   let userDefaultsManager = UserDefaultsManager.shared

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
	  cell.likeButton.setImage(UIImage(named: "heartFilled"), for: .normal)
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
	  if userDefaultsManager.isSongSaved(song: song) {
		 userDefaultsManager.deleteSongFromUserDefaults(song: song)
		 cell.likeButton.setImage(UIImage(named: "heart"), for: .normal)
	  } else {
		 userDefaultsManager.saveSongToUserDefaults(song: song)
		 cell.likeButton.setImage(UIImage(named: "heartFilled"), for: .normal)
	  }
   }
}
