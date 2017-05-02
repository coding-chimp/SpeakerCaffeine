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
    var devices = AudioDevice.allOutputDevices()

    if let index = devices.index(where: { $0.name == "Built-in Output" }) {
      let device = devices.remove(at: index)
      devices.insert(device, at: 0)
    }

    deviceNames = devices.map(deviceName)
  }

  private func deviceName(_ device: AudioDevice) -> String {
    if device.name != "Built-in Output" { return device.name }

    if device.isJackConnected(direction: .playback) ?? false {
      return "Headphones"
    } else {
      return "Internal Speakers"
    }
  }

  func isJackConnectedDidChange(for device: AudioDevice) {
    if device.name != "Built-in Output" { return }

    deviceNames[0] = deviceName(device)
  }
}
