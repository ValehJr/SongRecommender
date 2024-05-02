//
//  SongViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 13.04.24.
//

import UIKit
import AVFoundation

class SongViewController: UIViewController {

   weak var delegate: SongViewControllerDelegate?

   // MARK: Outlets
   @IBOutlet weak var heartButton: UIButton!
   @IBOutlet weak var playButton: UIButton!
   @IBOutlet weak var songProgress: UIProgressView!
   @IBOutlet weak var artistName: UILabel!
   @IBOutlet weak var songName: UILabel!
   @IBOutlet weak var songImage: UIImageView!

   // MARK: Variables
   var player: AVPlayer?
   var song_progress: Float?
   var timer:Timer?
   var isPlaying: Bool = false
   var song:Song?
   var playStateDidChange: ((Bool) -> Void)?
   var likedSongs = LikedViewController()

   // MARK: Managers
   let songFetcher = SongFetcher.shared
   let timeManager = TimeManager.shared

   // MARK: Lifecycle Methods
   override func viewDidLoad() {
	  super.viewDidLoad()
	  UISetup()
   }

   override func viewDidAppear(_ animated: Bool) {
	  songFetch()
	  let imageName = isPlaying ? "pause" : "play"
	  playButton.setImage(UIImage(named: imageName), for: .normal)
	  timeManager.startTimer(target: self, selector: #selector(updateProgress))
	  UISetup()
   }

   func UISetup() {
	  if isSongSaved() {
		 heartButton.setImage(UIImage(named: "heartFilled"), for: .normal)
	  } else {
		 heartButton.setImage(UIImage(named: "heart"), for: .normal)
	  }
	  if(song?.mp3_url == nil){
		 playButton.isHidden = true
		 songProgress.isHidden = true
	  }
   }

   // MARK: Button Functions
   @IBAction func heartButtonAction(_ sender: Any) {
	  if isSongSaved() {
		 deleteSongFromUserDefaults()
		 heartButton.setImage(UIImage(named: "heart"), for: .normal)
	  } else {
		 saveSongToUserDefaults()
		 heartButton.setImage(UIImage(named: "heartFilled"), for: .normal)
	  }
   }

   @IBAction func downButtonAction(_ sender: Any) {
	  transitioningDelegate = self
	  timeManager.stopTimer()
	  dismiss(animated: true) {
		 self.delegate?.songViewControllerDismissed()
	  }
   }

   @IBAction func playButtonAction(_ sender: Any) {
	  guard let player = player else { return }
	  if player.rate == 0 {
		 player.play()
		 playButton.setImage(UIImage(named: "pause"), for: .normal)
		 timeManager.startTimer(target: self, selector: #selector(updateProgress))
	  } else {
		 player.pause()
		 playButton.setImage(UIImage(named: "play"), for: .normal)
		 timeManager.stopTimer()
	  }
	  playStateDidChange?(player.rate != 0)
   }

   // MARK: UserDefaults save and delete functionality
   func saveSongToUserDefaults() {
	  guard let song = song else {
		 print("No song to save.")
		 return
	  }
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

   func deleteSongFromUserDefaults() {
	  guard let song = song else {
		 print("No song to delete.")
		 return
	  }
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

   func isSongSaved() -> Bool {
	  guard let songsData = UserDefaults.standard.array(forKey: "songs") as? [Data], let currentSong = song else {
		 return false
	  }
	  for songData in songsData {
		 do {
			let decoder = JSONDecoder()
			let savedSong = try decoder.decode(Song.self, from: songData)
			if savedSong == currentSong {
			   return true
			}
		 } catch {
			print("Error decoding song data:", error)
		 }
	  }
	  return false
   }


   // MARK: common functions
   func songFetch(){
	  artistName.text = song?.artist_name
	  songName.text = song?.track_name
	  songProgress.progress = song_progress ?? 0
	  if let imageUrl = URL(string: song?.image_url ?? " ") {
		 songFetcher.loadImage(from: imageUrl) { (image) in
			DispatchQueue.main.async{
			   self.songImage.image = image
			}
		 }
	  }
   }

   // MARK: objc functions
   @objc func updateProgress() {
	  guard let player = player else { return }
	  let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
	  let currentTime = CMTimeGetSeconds(player.currentTime())
	  let progress = Float(currentTime / duration)
	  songProgress.progress = progress
   }
}


extension SongViewController: UIViewControllerTransitioningDelegate {
   func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
	  return DismissAnimator()
   }
}
