//
//  AudioViewController.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 09.04.24.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    var player: AVPlayer?
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "https://p.scdn.co/mp3-preview/047e8976e8c483bfe9ccdc8773b429319741e99b?cid=d9219a18c2ed48e685ea287cbfcdda95") {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
        }
      playButton.setImage(UIImage(named: "play"), for: .normal)
    }

    @IBAction func playButtonAction(_ sender: Any) {
        guard let player = player else { return }

        if player.rate == 0 {
            player.play()
          playButton.setImage(UIImage(named: "pause"), for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        } else {
            player.pause()
          playButton.setImage(UIImage(named: "play"), for: .normal)
          timer?.invalidate()
            timer = nil
        }
    }

    @objc func updateProgress() {
        guard let player = player else { return }
        let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let progress = Float(currentTime / duration)
        progressView.setProgress(progress, animated: true)
    }
}
