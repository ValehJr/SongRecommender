//
//  HomeViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Cart on 08.04.24.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController,UIScrollViewDelegate {
  @IBOutlet weak var searchTableView: UITableView! {
    didSet {
      searchTableView.dataSource = self
      searchTableView.delegate = self
      let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
      searchTableView.register(nib, forCellReuseIdentifier: "SearchTableViewCell")
    }
  }

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

  var searchResults: [Song] = [] {
    didSet {
      searchTableView.reloadData()
    }
  }

  var displayedSongsCount = 0
  let songsPerPage = 9

  var player: AVPlayer?
  var timer: Timer?

  override func viewDidLoad() {
    super.viewDidLoad()
    UISetup()
    songView.isHidden = true

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(songViewTapped))

    searchField.addTarget(self, action: #selector(textFieldDidEndEditingOnExit(_:)), for: .editingDidEndOnExit)

  }

  @IBAction func refreshAction(_ sender: Any) {
    displayedSongsCount += songsPerPage
    songsTableVIew.reloadData()
  }

  func UISetup() {
    let placeholderColor = UIColor(red: 19/255, green: 19/255, blue: 19/255, alpha: 1)
    searchField.layer.cornerRadius = 15
    searchField.attributedPlaceholder = NSAttributedString(string: "Artists or songs", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
    songView.layer.cornerRadius = 7
    refreshButton.backgroundColor = .white
    refreshButton.layer.cornerRadius = 16
    refreshButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 16)
    searchTableView.isHidden = true
    searchTableView.layer.cornerRadius = 16
  }

  func fetchSongs(for query: String) {
    // Create the URL
    let urlString = "http://127.0.0.1:8000/getrecommendation/?search_string=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    guard let url = URL(string: urlString) else {
      print("Invalid URL")
      return
    }

    // Define the request parameters
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "accept")
    // Set the request body

    URLSession.shared.dataTask(with: request) { data, response, error in
      // Handle response
      if let error = error {
        print("Error fetching data: \(error)")
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Invalid HTTP response")
        return
      }

      guard httpResponse.statusCode == 200 else {
        print("HTTP status code: \(httpResponse.statusCode)")
        return
      }

      guard let data = data else {
        print("No data received")
        return
      }

      do {
        let songs = try JSONDecoder().decode([Song].self, from: data)
        DispatchQueue.main.async {
          self.searchResults = songs
          self.songsTableVIew.reloadData()
        }
      } catch {
        print("Error decoding JSON: \(error)")
      }
    }.resume()
  }

  @objc func textFieldDidEndEditingOnExit(_ textField: UITextField) {
    guard let text = textField.text else { return }
    fetchSongs(for: text)
  }

  @objc func songViewTapped() {
    guard let songViewController = storyboard?.instantiateViewController(withIdentifier: "songVC") as? SongViewController else { return }
    songViewController.modalPresentationStyle = .custom
    songViewController.transitioningDelegate = self
    present(songViewController, animated: true, completion: nil)
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

  @IBAction func playButtonAction(_ sender: Any) {
    guard let player = player else { return }

    if player.rate == 0 {
      player.play()
      playButton.setImage(UIImage(named: "pause"), for: .normal)
      timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    } else {
      player.pause()
      playButton.setImage(UIImage(named: "play"), for: .normal)
      timer?.invalidate()
      timer = nil
    }
  }

  @objc func updateProgress() {
    guard let player = player else { return }
    let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
    let currentTime = CMTimeGetSeconds(player.currentTime())
    let progress = Float(currentTime / duration)
    songProgress.setProgress(progress, animated: true)
  }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchResults.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if tableView == songsTableVIew {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableViewCell", for: indexPath) as! SongsTableViewCell
      let song = searchResults[indexPath.item]
      cell.nameLabel.text = song.track_name
      cell.artistLabel.text = song.artist_name
      if let imageUrl = URL(string: song.image_url) {
        loadImage(from: imageUrl) { (image) in
          DispatchQueue.main.async{
            cell.songImage.image = image
          }
        }
      }
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
      return cell
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let song = searchResults[indexPath.item]
    songName.text = song.track_name
    artistName.text = song.artist_name
    if let imageUrl = URL(string: song.image_url) {
      loadImage(from: imageUrl) { (image) in
        DispatchQueue.main.async{
          self.songImage.image = image
        }
      }
    }
    if let mp3UrlString = song.mp3_url, let url = URL(string: mp3UrlString) {
      playButton.setImage(UIImage(named: "play"), for: .normal)
      let playerItem = AVPlayerItem(url: url)
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
