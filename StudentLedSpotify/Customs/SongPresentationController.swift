//
//  SongPresentationController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 13.04.24.
//

import UIKit

class SongPresentationController: UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        let frame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
        return frame
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView else { return }
        containerView.addSubview(presentedView)
    }
}
