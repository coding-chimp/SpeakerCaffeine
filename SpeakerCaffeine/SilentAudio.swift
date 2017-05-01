//
//  SilentAudio.swift
//  SpeakerCaffeine
//
//  Created by Bastian Bartmann on 01.05.17.
//  Copyright © 2017 Bastian Bartmann. All rights reserved.
//

import AVFoundation
import SwiftyTimer

class SilentAudio {
  fileprivate var audioPlayer: AVAudioPlayer?
  fileprivate var timer: Timer?

  init() {
    timer = nil
  }

  func periodicallyPlay() {
    if timer == nil {
      playAudio()

      timer = Timer.new(every: 1.minute, playAudio)
      timer?.start(modes: .commonModes)
    }
  }

  func stop() {
    if timer != nil {
      timer?.invalidate()
      timer = nil
    }
  }

  private func playAudio() {
    let asset = NSDataAsset(name: "SilentAudio")!

    do {
      audioPlayer = try AVAudioPlayer(data: asset.data, fileTypeHint: "wav")
      guard let audioPlayer = audioPlayer else { return }

      audioPlayer.prepareToPlay()
      audioPlayer.play()
    } catch let error {
      print(error.localizedDescription)
    }
  }
}
