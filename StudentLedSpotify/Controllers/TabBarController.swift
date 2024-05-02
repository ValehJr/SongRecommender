//
//  TabBarController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 08.03.24.
//

import UIKit

class TabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.setHidesBackButton(true, animated: true)
  }

}
