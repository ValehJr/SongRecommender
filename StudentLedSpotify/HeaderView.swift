//
//  HeaderView.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 01.05.24.
//

import UIKit
class HeaderView: UIView {

   @IBOutlet weak var profileImageView: UIImageView!
   @IBOutlet weak var infoView: UIView!
   @IBOutlet weak var songsCount: UILabel!
   @IBOutlet weak var userName: UILabel!
   @IBOutlet weak var playlistName: UILabel!
   @IBOutlet weak var playlistImageView: UIImageView!

   override init(frame:CGRect){
	  super.init(frame: frame)
   }

   required init?(coder: NSCoder) {
	  super.init(coder: coder)
   }


   func configureView(profileImageView:UIImage, playlistImageView:UIImage,userName:String,playlistName:String,songsCount:String){
	  self.playlistImageView.image = playlistImageView
	  self.playlistImageView.layer.cornerRadius = 12
	  self.profileImageView.image = profileImageView
	  self.profileImageView.layer.cornerRadius = 12
	  self.infoView.layer.cornerRadius = 16
	  self.playlistName.text = playlistName
	  self.songsCount.text = songsCount
	  self.userName.text = userName
   }

}
