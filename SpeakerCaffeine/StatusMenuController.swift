//
//  StatusMenuController.swift
//  SpeakerCaffeine
//
//  Created by Bastian Bartmann on 10.04.17.
//  Copyright © 2017 Bastian Bartmann. All rights reserved.
//

import Cocoa
import AVFoundation
import SwiftyTimer

class StatusMenuController: NSObject {

  var audioPlayer: AVAudioPlayer?

  let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

  @IBOutlet weak var statusMenu: NSMenu!

  @IBAction func quitClicked(_ sender: Any) {
    NSApplication.shared().terminate(self)
  }
  
  override func awakeFromNib() {
    statusItem.title = "SpeakerCaffeine"
    statusItem.menu = statusMenu

    periodicallyPlayAudio()
  }

  func periodicallyPlayAudio() {
    Timer.every(1.minute, playAudio)
  }

  func playAudio() {
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
