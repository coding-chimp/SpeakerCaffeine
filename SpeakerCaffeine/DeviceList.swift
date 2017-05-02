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
  let defaults: UserDefaults
  var delegate: DeviceListDelegate?
  private var deviceNames: [String] {
    didSet {
      delegate?.deviceNamesChanged(oldDeviceNames: oldValue, newDeviceNames: deviceNames)
    }
  }
  private var enabledDevices: Set<String>

  init() {
    defaults = UserDefaults.standard
    deviceNames = []
    enabledDevices = Set(defaults.stringArray(forKey: "enabledDevices") ?? [])
  }

  func populate() {
    var devices = AudioDevice.allOutputDevices()

    if let index = devices.index(where: { $0.name == "Built-in Output" }) {
      let device = devices.remove(at: index)
      devices.insert(device, at: 0)
    }

    var deviceNames = devices.map(deviceName)

    let missingEnabledDevices = enabledDevices.subtracting(deviceNames)
    deviceNames.append(contentsOf: missingEnabledDevices)

    self.deviceNames = deviceNames
  }

  func currentDeviceEnabled() -> Bool {
    let currentDeviceName = AudioDevice.defaultOutputDevice()?.name ?? ""

    return enabledDevices.contains(currentDeviceName)
  }

  func state(for deviceName: String) -> Int {
    if enabledDevices.contains(deviceName) {
      return NSOnState
    } else {
      return NSOffState
    }
  }

  func toggle(_ deviceName: String) {
    if let index = enabledDevices.index(of: deviceName) {
      enabledDevices.remove(at: index)
    } else {
      enabledDevices.insert(deviceName)
    }

    defaults.setValue(Array(enabledDevices), forKey: "enabledDevices")
    populate()
  }

  func isJackConnectedDidChange(for device: AudioDevice) {
    if device.name == "Built-in Output" {
      populate()
    }
  }

  private func deviceName(_ device: AudioDevice) -> String {
    if device.name != "Built-in Output" { return device.name }

    if device.isJackConnected(direction: .playback) ?? false {
      return "Headphones"
    } else {
      return "Internal Speakers"
    }
  }
}
