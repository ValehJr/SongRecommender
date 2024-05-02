//
//  LikedSongsTableViewCell.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 02.05.24.
//

import UIKit

protocol LikedSongsTableViewCellDelegate: AnyObject {
   func likeButtonDidTap(cell: LikedSongsTableViewCell)
}

class LikedSongsTableViewCell: UITableViewCell {

   weak var delegate: LikedSongsTableViewCellDelegate?
   let likedVC = LikedViewController()

   @IBOutlet weak var likeButton: UIButton!
   @IBOutlet weak var artistName: UILabel!
   @IBOutlet weak var songName: UILabel!
   @IBOutlet weak var songImageView: UIImageView!

   override func awakeFromNib() {
	  super.awakeFromNib()
	  likeButton.setImage(UIImage(named: "heartFilled"), for: .normal)
   }

   override func setSelected(_ selected: Bool, animated: Bool) {
	  super.setSelected(selected, animated: animated)
   }

   @IBAction func likeButtonAction(_ sender: Any) {
	  delegate?.likeButtonDidTap(cell: self)
   }
}
