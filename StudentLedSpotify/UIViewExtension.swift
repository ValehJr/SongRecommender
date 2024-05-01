//
//  UIViewExtension.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 01.05.24.
//

import Foundation
import UIKit

extension UIView {
  func loadFromNib(nibName: String) -> UIView? {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: nibName, bundle: bundle)
    return nib.instantiate(withOwner: self, options: nil).first as? UIView
  }
}
