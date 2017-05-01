//
//  StatusMenuController.swift
//  SpeakerCaffeine
//
//  Created by Bastian Bartmann on 10.04.17.
//  Copyright © 2017 Bastian Bartmann. All rights reserved.
//

import Cocoa
import AMCoreAudio

class StatusMenuController: NSObject {
  let silentAudio = SilentAudio()
  let startIndex = 1
  let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

  @IBOutlet weak var statusMenu: NSMenu!

  @IBAction func quitClicked(_ sender: Any) {
    NSApplication.shared().terminate(self)
  }
  
  override func awakeFromNib() {
    statusItem.title = "SpeakerCaffeine"
    statusItem.menu = statusMenu

    let deviceNames = getDeviceNames()

    for (index, deviceName) in deviceNames.enumerated() {
      addDeviceMenuItem(deviceName, position: startIndex + index)
    }

    silentAudio.periodicallyPlay()
  }

  private func getDeviceNames() -> [String] {
    var deviceNames = AudioDevice.allOutputDevices().map(deviceName)
    let currentDevice = AudioDevice.defaultOutputDevice()

    if let device = currentDevice, deviceIsHeadphone(device) {
      deviceNames.insert("Headphones", at: 0)
    }

    return deviceNames
  }

  private func deviceName(_ device: AudioDevice) -> String {
    if device.name == "Built-in Output" {
      return "Internal Speakers"
    } else {
      return device.name
    }
  }

  private func deviceIsHeadphone(_ device: AudioDevice) -> Bool {
    return device.name == "Built-in Output" && device.isJackConnected(direction: .playback) ?? false
  }

  func addDeviceMenuItem(_ deviceName: String, position: Int) {
    let item = NSMenuItem(title: deviceName, action: nil, keyEquivalent: "")
    item.target = self

    statusMenu.insertItem(item, at: position)
  }
}
