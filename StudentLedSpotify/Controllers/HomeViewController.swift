//
//  HomeViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.04.24.
//

import UIKit

class HomeViewController: UIViewController,UIScrollViewDelegate {

  var searchWorkItem: DispatchWorkItem?

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

  var currentOffset = 0
  let chunkSize = 15

  var invalid = 0

  var Songs = [Song]()

  override func viewDidLoad() {
    super.viewDidLoad()
    UISetup()
    searchField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    songView.isHidden = true

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(songViewTapped))
    songView.addGestureRecognizer(tapGesture)
    DispatchQueue.global().async {
      self.loadNextChunk()
      self.loadMoreData()
    }
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

  @objc func textFieldDidChange(_ textField: UITextField) {
      searchWorkItem?.cancel()
      let query = textField.text ?? ""
    if(query.isEmpty){
      searchTableView.isHidden = true
    } else {
      searchTableView.isHidden  = false
    }

      let workItem = DispatchWorkItem { [weak self] in
          guard let self = self else { return }
          let filteredSongs = self.Songs.filter { $0.trackName.lowercased().contains(query.lowercased()) || $0.artistName.lowercased().contains(query.lowercased())}
          print("Filtered Songs: \(filteredSongs)")

          DispatchQueue.main.async {
              self.searchResults = filteredSongs
          }
      }
      searchWorkItem = workItem
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: workItem)
  }

  @objc func songViewTapped() {
    guard let songViewController = storyboard?.instantiateViewController(withIdentifier: "songVC") as? SongViewController else { return }
    songViewController.modalPresentationStyle = .custom
    songViewController.transitioningDelegate = self
    present(songViewController, animated: true, completion: nil)
  }

  func loadNextChunk() {
    guard let filePath = Bundle.main.path(forResource: "artists_songs", ofType: "csv") else {
      return
    }

    do {
      let data = try String(contentsOfFile: filePath, encoding: .utf8)
      var rows = data.components(separatedBy: "\n")
      rows.removeFirst() // Remove header

      let endIndex = min(currentOffset + chunkSize, rows.count)
      let chunk = rows[currentOffset..<endIndex]
      currentOffset = endIndex

      DispatchQueue.global().async {
        for row in chunk {
          let columns = row.components(separatedBy: ",")
          if columns.count >= 4 {
            let artistName = columns[1]
            let trackName = columns[2]
            let trackID = columns[3]
            let song = Song(artistName: artistName, trackName: trackName, trackID: trackID)
            self.Songs.append(song)
          } else {
            print("Invalid row: \(row)")
          }
        }

        DispatchQueue.main.async {
          self.searchTableView.reloadData()
        }
      }
    } catch {
      print(error)
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
       let contentHeight = scrollView.contentSize.height
       let screenHeight = scrollView.frame.size.height

       // Check if user has scrolled to the bottom and if searchTableView is visible
       if offsetY > contentHeight - screenHeight, scrollView == searchTableView {
           loadMoreData()
       }
  }

  func loadMoreData() {
    let endIndex = min(currentOffset + chunkSize, Songs.count)
    guard currentOffset < Songs.count else {
      // All data has been loaded
      return
    }

    let additionalSongs = Songs[currentOffset..<endIndex]
    currentOffset = endIndex

    DispatchQueue.main.async {
      // Append the new data to searchResults
      self.searchResults.append(contentsOf: additionalSongs)
      self.searchTableView.reloadData()
    }
  }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if(tableView == searchTableView ){
      return searchResults.count
    } else {
      return min(displayedSongsCount, searchResults.count)
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if(tableView == songsTableVIew){
      let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableViewCell", for: indexPath) as! SongsTableViewCell
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as! SearchTableViewCell
      let song = Songs[indexPath.item]
      cell.songNameLabel.text = song.trackName
      return cell
    }

  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    songView.isHidden = false
    let song = Songs[indexPath.row]
    songName.text = song.trackName
    artistName.text = song.artistName
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
