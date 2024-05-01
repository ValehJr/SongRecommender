//
//  Animation.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 26.04.24.
//

import Foundation
import UIKit
import Lottie

class AnimationManager {
  static let shared = AnimationManager()

  private init() {}

  func setupAnimationInView(_ view: UIView) -> LottieAnimationView {
    let animationWidth: CGFloat = 200
    let animationHeight: CGFloat = 100
    let xPosition = (view.frame.width - animationWidth) / 2
    let yPosition = (view.frame.height - animationHeight) / 2
    let animationView = LottieAnimationView(name: "loading")
    animationView.frame = CGRect(x: xPosition, y: yPosition, width: animationWidth, height: animationHeight)
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .loop
    animationView.animationSpeed = 1.0
    view.addSubview(animationView)
    animationView.play()

    return animationView
  }

  func removeAnimation(_ animationView: LottieAnimationView) {
    animationView.removeFromSuperview()
  }
}
