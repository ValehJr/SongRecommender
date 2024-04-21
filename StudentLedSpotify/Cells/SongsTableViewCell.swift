//
//  SearchTableViewCell.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.04.24.
//

import UIKit

class SongsTableViewCell: UITableViewCell {

  @IBOutlet weak var spotifyImage: UIImageView!
  @IBOutlet weak var songImage: UIImageView!
  @IBOutlet weak var artistLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
