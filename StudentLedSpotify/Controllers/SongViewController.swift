//
//  SongViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 13.04.24.
//

import UIKit

class SongViewController: UIViewController {

  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var songProgress: UIProgressView!
  @IBOutlet weak var artistName: UILabel!
  @IBOutlet weak var songName: UILabel!
  @IBOutlet weak var songImage: UIImageView!
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
  @IBAction func downButtonAction(_ sender: Any) {
    transitioningDelegate = self
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func playButtonAction(_ sender: Any) {
  }

}

extension SongViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}
