//
//  AbreviationString.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 03.05.24.
//

import Foundation
import UIKit

extension String {
   func abbreviatedTimeFormat() -> String {
	  var formattedString = self.replacingOccurrences(of: " hours", with: " hr")
	  formattedString = formattedString.replacingOccurrences(of: " minutes", with: " min")
	  return formattedString
   }
}
