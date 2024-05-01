//
//  TabBarController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.04.24.
//

import UIKit

class TabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.setHidesBackButton(true, animated: true)
  }

}
//self.headerView.userName.text = "\(self.playlist?.username ?? "")"
//self.headerView.songsCount.text = " \(self.playlist?.n_tracks ?? 0) songs, \(self.playlist?.duration.abbreviatedDuration() ?? "")"
//self.headerView.playlistName.text = self.playlist?.playlist
//if let imageUrl = URL(string: self.playlist?.image ?? "") {
//  self.songFetcher.loadImage(from: imageUrl) { (image) in
//    DispatchQueue.main.async{
//      self.headerView.playlistImageView.image = image
//    }
//  }
//}
