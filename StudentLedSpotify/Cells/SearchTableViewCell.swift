//
//  SearchTableViewCell.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 14.03.24.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

  @IBOutlet weak var songNameLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
