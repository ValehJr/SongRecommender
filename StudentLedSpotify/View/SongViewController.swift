//
//  SongViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 13.03.24.
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
   let userDefaultsManager = UserDefaultsManager.shared

   // MARK: Lifecycle Methods
   override func viewDidLoad() {
	  super.viewDidLoad()
   }

   override func viewDidAppear(_ animated: Bool) {
	  songFetch()
	  let imageName = isPlaying ? "pause" : "play"
	  playButton.setImage(UIImage(named: imageName), for: .normal)
	  timeManager.startTimer(target: self, selector: #selector(updateProgress))
	  DispatchQueue.main.async {
		 self.UISetup()
	  }
   }

   func UISetup() {
	  if let song = song {
		 if userDefaultsManager.isSongSaved(song: song) {
			heartButton.setImage(UIImage(named: "heartFilled"), for: .normal)
		 } else {
			heartButton.setImage(UIImage(named: "heart"), for: .normal)
		 }
		 if(song.mp3_url == nil){
			playButton.isHidden = true
			songProgress.isHidden = true
		 }
	  }
   }

   // MARK: Button Functions
   @IBAction func heartButtonAction(_ sender: Any) {
	  if let song = song {
		 if userDefaultsManager.isSongSaved(song: song) {
			userDefaultsManager.deleteSongFromUserDefaults(song: song)
			heartButton.setImage(UIImage(named: "heart"), for: .normal)
		 } else {
			userDefaultsManager.saveSongToUserDefaults(song: song)
			heartButton.setImage(UIImage(named: "heartFilled"), for: .normal)
		 }
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
