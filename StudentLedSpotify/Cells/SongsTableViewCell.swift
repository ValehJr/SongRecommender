//
//  SearchTableViewCell.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.03.24.
//

import UIKit

class SongsTableViewCell: UITableViewCell {

   @IBOutlet weak var spotifyImage: UIImageView!
   @IBOutlet weak var songImage: UIImageView!
   @IBOutlet weak var artistLabel: UILabel!
   @IBOutlet weak var nameLabel: UILabel!

   let songFetcher = SongFetcher.shared

   override func awakeFromNib() {
	  super.awakeFromNib()
	  // Initialization code
   }

   override func setSelected(_ selected: Bool, animated: Bool) {
	  super.setSelected(selected, animated: animated)

	  // Configure the view for the selected state
   }

   func configure(with song: Song) {
	  nameLabel.text = song.track_name
	  artistLabel.text = song.artist_name

	  if let imageUrl = URL(string: song.image_url) {
		 songFetcher.loadImage(from: imageUrl) { [weak self] (image) in
			DispatchQueue.main.async {
			   self?.songImage.image = image
			}
		 }
	  }

	  if song.mp3_url != nil {
		 spotifyImage.image = nil
	  } else {
		 spotifyImage.image = UIImage(named: "spotify")
	  }
   }

}
