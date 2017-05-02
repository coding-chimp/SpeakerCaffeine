//
//  DeviceList.swift
//  SpeakerCaffeine
//
//  Created by Bastian Bartmann on 02.05.17.
//  Copyright © 2017 Bastian Bartmann. All rights reserved.
//

import AMCoreAudio
import Cocoa

protocol DeviceListDelegate {
  func deviceNamesChanged(oldDeviceNames: [String], newDeviceNames: [String])
}

class DeviceList {
  var delegate: DeviceListDelegate?
  private var deviceNames: [String] {
    didSet {
      delegate?.deviceNamesChanged(oldDeviceNames: oldValue, newDeviceNames: deviceNames)
    }
  }

  init() {
    deviceNames = []
  }

  func generate() {
    let devices = AudioDevice.allOutputDevices()
    var deviceNames = devices.map(deviceName)

    if devices.contains(where: deviceIsHeadphones) {
      deviceNames.insert("Headphones", at: 0)
    }

    self.deviceNames = deviceNames
  }

  private func deviceName(_ device: AudioDevice) -> String {
    if device.name == "Built-in Output" {
      return "Internal Speakers"
    } else {
      return device.name
    }
  }

  private func deviceIsHeadphones(_ device: AudioDevice) -> Bool {
    return device.name == "Built-in Output" && device.isJackConnected(direction: .playback) ?? false
  }

  func isJackConnectedDidChange(for device: AudioDevice) {
    if device.name != "Built-in Output" { return }

    if let index = deviceNames.index(of: "Headphones") {
      deviceNames.remove(at: index)
    }

    if device.isJackConnected(direction: .playback) ?? false {
      deviceNames.insert("Headphones", at: 0)
    }
  }
}
