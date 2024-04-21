//
//  SongViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 13.04.24.
//

import UIKit
import AVFoundation

class SongViewController: UIViewController {

  @IBOutlet weak var heartButton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var songProgress: UIProgressView!
  @IBOutlet weak var artistName: UILabel!
  @IBOutlet weak var songName: UILabel!
  @IBOutlet weak var songImage: UIImageView!

  var player: AVPlayer?
  var song_progress: Float?
  var timer:Timer?
  var isPlaying: Bool = false

  var song:Song?

  var playStateDidChange: ((Bool) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()

    if isSongSaved() {
      heartButton.setImage(UIImage(named: "heartFilled"), for: .normal)
    } else {
      heartButton.setImage(UIImage(named: "heart"), for: .normal)
    }

  }

  override func viewDidAppear(_ animated: Bool) {
    songFetch()
    let imageName = isPlaying ? "pause" : "play"
    playButton.setImage(UIImage(named: imageName), for: .normal)
    startTimer()
  }

  func songFetch(){
    artistName.text = song?.artist_name
    songName.text = song?.track_name
    songProgress.progress = song_progress ?? 0
    if let imageUrl = URL(string: song?.image_url ?? " ") {
      loadImage(from: imageUrl) { (image) in
        DispatchQueue.main.async{
          self.songImage.image = image
        }
      }
    }
  }

  @IBAction func heartButtonAction(_ sender: Any) {
    if isSongSaved() {
      deleteSongFromUserDefaults()
      heartButton.setImage(UIImage(named: "heart"), for: .normal)
    } else {
      saveSongToUserDefaults()
      heartButton.setImage(UIImage(named: "heartFilled"), for: .normal)
    }
  }

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

      print("Song saved to UserDefaults.")
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
    print("Song deleted from UserDefaults.")
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



  @IBAction func downButtonAction(_ sender: Any) {
    transitioningDelegate = self
    stopTimer()
    dismiss(animated: true, completion: nil)
  }

  @IBAction func playButtonAction(_ sender: Any) {
    guard let player = player else { return }

    if player.rate == 0 {
      player.play()
      playButton.setImage(UIImage(named: "pause"), for: .normal)
      startTimer()
    } else {
      player.pause()
      playButton.setImage(UIImage(named: "play"), for: .normal)
      stopTimer()
    }
    playStateDidChange?(player.rate != 0)
  }

  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
  }

  func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    let session = URLSession.shared
    let task = session.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("Error loading image: \(error)")
        completion(nil)
        return
      }

      guard let data = data, let image = UIImage(data: data) else {
        print("Invalid image data")
        completion(nil)
        return
      }
      completion(image)
    }

    task.resume()
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

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
