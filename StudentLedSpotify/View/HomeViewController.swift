//
//  HomeViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.03.24.
//

import UIKit
import AVFoundation
import Lottie

class HomeViewController: UIViewController, UIScrollViewDelegate {

   // MARK: Outlets
   @IBOutlet weak var refreshButton: UIButton!
   @IBOutlet weak var songProgress: UIProgressView!
   @IBOutlet weak var songName: UILabel!
   @IBOutlet weak var songImage: UIImageView!
   @IBOutlet weak var artistName: UILabel!
   @IBOutlet weak var playButton: UIButton!
   @IBOutlet weak var songView: UIView!
   @IBOutlet weak var searchField: PaddedTextField!
   @IBOutlet weak var songsTableVIew: UITableView! {
	  didSet {
		 songsTableVIew.delegate = self
		 songsTableVIew.dataSource = self
		 let nib = UINib(nibName: "SongsTableViewCell", bundle: nil)
		 songsTableVIew.register(nib, forCellReuseIdentifier: "SongsTableViewCell")
	  }
   }

   // MARK: Properties
   var recomendSongs: [Song] = []

   var selectedIndexPath: IndexPath?

   var player: AVPlayer?
   var timer: Timer?
   var displayedSongsCount = 8

   let songFetcher = SongFetcher.shared
   let timeManager = TimeManager.shared
   let animationManager = AnimationManager.shared

   var animationView: LottieAnimationView!

   // MARK: Lifecycle Methods
   override func viewDidLoad() {
	  super.viewDidLoad()
	  UISetup()
	  songView.isHidden = true
	  let tapGesture = UITapGestureRecognizer(target: self, action: #selector(songViewTapped))
	  songView.addGestureRecognizer(tapGesture)
	  searchField.addTarget(self, action: #selector(textFieldDidEndEditingOnExit(_:)), for: .editingDidEndOnExit)
   }

   override func viewDidAppear(_ animated: Bool) {
	  tabBarConfigure()
   }

   // MARK: UI Setup
   func UISetup() {
	  let placeholderColor = UIColor(red: 19/255, green: 19/255, blue: 19/255, alpha: 1)
	  searchField.layer.cornerRadius = 15
	  searchField.attributedPlaceholder = NSAttributedString(string: "Artists or songs", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
	  songView.layer.cornerRadius = 7
	  refreshButton.backgroundColor = .white
	  refreshButton.layer.cornerRadius = 16
	  refreshButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
	  refreshButton.isHidden = true
	  tabBarConfigure()
   }

   func setupAnimation() {
	  animationView = animationManager.setupAnimationInView(view)
   }

   func removeAnimation() {
	  if let animationView = animationView {
		 self.animationManager.removeAnimation(animationView)
		 self.animationView = nil
	  }
   }


   // MARK: Tab Bar Configuration
   func tabBarConfigure(){
	  let tabBarItem = UITabBarItem(title: "Song", image: UIImage(named: "searchGray"), selectedImage: UIImage(named: "searchWhite"))
	  self.tabBarItem = tabBarItem
   }

   // MARK: IBActions
   @IBAction func refreshAction(_ sender: Any) {
	  displayedSongsCount += 8
	  songsTableVIew.reloadData()
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
   }

   // MARK: Helper Methods
   @objc func updateProgress() {
	  guard let player = player else { return }
	  let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
	  let currentTime = CMTimeGetSeconds(player.currentTime())
	  let progress = Float(currentTime / duration)
	  songProgress.setProgress(progress, animated: true)
   }

   // MARK: Text Field Actions
   @objc func textFieldDidEndEditingOnExit(_ textField: UITextField) {
	  setupAnimation()
	  recomendSongs = []
	  songsTableVIew.reloadData()
	  refreshButton.isHidden = true
	  songView.isHidden = true
	  self.player?.pause()

	  guard let text = textField.text else { return }
	  songFetcher.fetchSongs(for: text) { [weak self] songs, error in
		 guard let self = self else { return }
		 if let error = error {
			print("Error fetching songs: \(error)")
			DispatchQueue.main.async {
			   self.removeAnimation()
			   self.showAlert(message: error.localizedDescription)
			}
			return
		 }
		 if let songs = songs {
			self.recomendSongs = songs
			DispatchQueue.main.async {
			   self.songsTableVIew.reloadData()
			   self.refreshButton.isHidden = false
			   self.removeAnimation()
			}
		 }
	  }
	  displayedSongsCount = 8
   }


   func showAlert(message: String) {
	  DispatchQueue.main.async {
		 if let animationView = self.animationView {
			animationView.removeFromSuperview()
		 }
		 let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		 alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		 if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			let topViewController = windowScene.windows.first?.rootViewController {
			topViewController.present(alertController, animated: true, completion: nil)
		 }
	  }
   }

   // MARK: Song View Gesture
   @objc func songViewTapped() {
	  guard let indexPath = selectedIndexPath else {
		 print("No index path selected.")
		 return
	  }

	  guard let songViewController = storyboard?.instantiateViewController(withIdentifier: "songVC") as? SongViewController else {
		 print("Failed to instantiate SongViewController.")
		 return
	  }

	  songViewController.modalPresentationStyle = .custom
	  songViewController.transitioningDelegate = self

	  guard indexPath.row < recomendSongs.count else {
		 print("Selected index path out of bounds.")
		 return
	  }

	  let selectedSong = recomendSongs[indexPath.row]
	  songViewController.song = selectedSong
	  songViewController.player = player
	  songViewController.isPlaying = (player?.rate != 0)

	  songViewController.playStateDidChange = { [weak self] isPlaying in
		 self?.playButton.setImage(UIImage(named: isPlaying ? "pause" : "play"), for: .normal)
		 if !isPlaying {
			self?.player?.pause()
		 }
	  }
	  present(songViewController, animated: true, completion: nil)
   }


}

// MARK: Table View Data Source & Delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	  return min(displayedSongsCount, recomendSongs.count)
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	  let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableViewCell", for: indexPath) as! SongsTableViewCell
	  let song = recomendSongs[indexPath.row]
	  cell.configure(with: song)
	  return cell
   }

   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	  let song = recomendSongs[indexPath.item]
	  selectedIndexPath = indexPath
	  songName.text = song.track_name
	  artistName.text = song.artist_name
	  if let imageUrl = URL(string: song.image_url) {
		 songFetcher.loadImage(from: imageUrl) { (image) in
			DispatchQueue.main.async{
			   self.songImage.image = image
			}
		 }
	  }
	  if let mp3UrlString = song.mp3_url, let url = URL(string: mp3UrlString) {
		 playButton.isHidden = false
		 playButton.setImage(UIImage(named: "pause"), for: .normal)
		 let playerItem = AVPlayerItem(url: url)
		 player?.pause()
		 player = AVPlayer(playerItem: playerItem)
		 player?.play()
		 timeManager.startTimer(target: self, selector: #selector(updateProgress))
	  } else if let spotifyUrlString = song.spotify_url, let url = URL(string: spotifyUrlString) {
		 player?.pause()
		 playButton.isHidden = true
		 let alertController = UIAlertController(title: "Redirect to Spotify", message: "You will be redirected to Spotify, do you want to proceed?", preferredStyle: .alert)
		 alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
		 alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		 }))
		 self.present(alertController, animated: true, completion: nil)
	  } else {
		 print("Both mp3_url and spotify_url are null")
	  }
	  songView.isHidden = false
   }
}

// MARK: Transition Delegate
extension HomeViewController: UIViewControllerTransitioningDelegate {
   func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
	  return SongPresentationController(presentedViewController: presented, presenting: presenting)
   }

   func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
	  return SongTransitionAnimator()
   }

   func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
	  return nil
   }
}
