//
//  PlaylistViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 22.04.24.
//

import UIKit
import AVFoundation

class PlaylistViewController: UIViewController {

  // MARK: Outlets
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var songProgress: UIProgressView!
  @IBOutlet weak var songImageView: UIImageView!
  @IBOutlet weak var artistName: UILabel!
  @IBOutlet weak var songName: UILabel!
  @IBOutlet weak var songView: UIView!
  @IBOutlet weak var searchTextField: PaddedTextField!
  @IBOutlet weak var refreshButton: UIButton!
  @IBOutlet weak var songsTableVIew: UITableView! {
    didSet {
      songsTableVIew.delegate = self
      songsTableVIew.dataSource = self
      let nib = UINib(nibName: "SongsTableViewCell", bundle: nil)
      songsTableVIew.register(nib, forCellReuseIdentifier: "SongsTableViewCell")
    }
  }

  // MARK: Properties
  var playlist: Playlist?

  var player: AVPlayer?
  var timer: Timer?
  var displayedSongsCount = 8

  let songFetcher = SongFetcher.shared
  let timeManager = TimeManager.shared

  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    UISetup()
    songView.isHidden = true
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(songViewTapped))
    songView.addGestureRecognizer(tapGesture)
    searchTextField.addTarget(self, action: #selector(textFieldDidEndEditingOnExit(_:)), for: .editingDidEndOnExit)
  }

  override func viewDidAppear(_ animated: Bool) {
    tabBarConfigure()
  }

  // MARK: UI Setup
  func UISetup() {
    let placeholderColor = UIColor(red: 19/255, green: 19/255, blue: 19/255, alpha: 1)
    searchTextField.layer.cornerRadius = 15
    searchTextField.attributedPlaceholder = NSAttributedString(string: "Playlist url...", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
    songView.layer.cornerRadius = 7
    refreshButton.backgroundColor = .white
    refreshButton.layer.cornerRadius = 16
    refreshButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
    tabBarConfigure()
  }

  // MARK: Tab Bar Configuration
  func tabBarConfigure(){
    let tabBarItem = UITabBarItem(title: "Playlist", image: UIImage(named: "searchGray"), selectedImage: UIImage(named: "searchWhite"))
    self.tabBarItem = tabBarItem
  }

  @IBAction func refreshButtonAction(_ sender: Any) {
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
    guard let text = textField.text else { return }
    songFetcher.fetchPlaylistSongs(for: text) { [weak self] fetchedPlaylist, error in
      guard let self = self else { return }
      if let error = error {
        print("Error fetching playlist: \(error)")
        return
      }
      if let fetchedPlaylist = fetchedPlaylist {
        self.playlist = fetchedPlaylist
        DispatchQueue.main.async {
          self.songsTableVIew.reloadData()
        }
      }
    }
    displayedSongsCount = 8
  }

  // MARK: Song View Gesture
  @objc func songViewTapped() {
    guard let songViewController = storyboard?.instantiateViewController(withIdentifier: "songVC") as? SongViewController else { return }
    songViewController.modalPresentationStyle = .custom
    songViewController.transitioningDelegate = self
    if let selectedIndexPath = songsTableVIew.indexPathForSelectedRow {
      let selectedSong = playlist?.songs[selectedIndexPath.row]
      songViewController.song = selectedSong
      songViewController.player = player
      songViewController.isPlaying = (player?.rate != 0)
      songViewController.playStateDidChange = { [weak self] isPlaying in
        self?.playButton.setImage(UIImage(named: isPlaying ? "pause" : "play"), for: .normal)
        if !isPlaying {
          self?.player?.pause()
        }
      }
    }
    present(songViewController, animated: true, completion: nil)
  }
}

// MARK: Table View Data Source & Delegate
extension PlaylistViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return min(displayedSongsCount, playlist?.songs.count ?? 0)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableViewCell", for: indexPath) as! SongsTableViewCell
    guard let song = playlist?.songs[indexPath.row] else {
      return cell
    }
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

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let song = playlist?.songs[indexPath.row] else {
      return
    }
    songName.text = song.track_name
    artistName.text = song.artist_name
    if let imageUrl = URL(string: song.image_url) {
      songFetcher.loadImage(from: imageUrl) { (image) in
        DispatchQueue.main.async{
          self.songImageView.image = image
        }
      }
    }
    if let mp3UrlString = song.mp3_url, let url = URL(string: mp3UrlString) {
      playButton.setImage(UIImage(named: "play"), for: .normal)
      let playerItem = AVPlayerItem(url: url)
      player?.pause()
      player = AVPlayer(playerItem: playerItem)
      songView.isHidden = false
    } else if let spotifyUrlString = song.spotify_url, let url = URL(string: spotifyUrlString) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
      print("Both mp3_url and spotify_url are null")
    }
    songView.isHidden = false
  }
}

// MARK: Transition Delegate
extension PlaylistViewController: UIViewControllerTransitioningDelegate {
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

