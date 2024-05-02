//
//  SongTransitionAnimator.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 13.03.24.
//

import Foundation
import UIKit

class SongTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let completion: (() -> Void)?

    init(completion: (() -> Void)? = nil) {
        self.completion = completion
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        toViewController.view.frame = containerView.bounds
        toViewController.view.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

        containerView.addSubview(toViewController.view)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toViewController.view.transform = .identity
        }, completion: { finished in
            transitionContext.completeTransition(finished)
            self.completion?() 
        })
    }
}
