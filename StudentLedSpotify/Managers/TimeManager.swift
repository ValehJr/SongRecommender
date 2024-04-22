//
//  TimeManager.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 22.04.24.
//

import Foundation

class TimeManager {
  static let shared = TimeManager()
  
  var timer: Timer?

  func startTimer(target: Any, selector: Selector) {
    timer = Timer.scheduledTimer(timeInterval: 0.1, target: target, selector: selector, userInfo: nil, repeats: true)
  }

  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
}
