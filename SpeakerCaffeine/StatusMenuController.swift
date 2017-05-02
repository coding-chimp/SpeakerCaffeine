//
//  StatusMenuController.swift
//  SpeakerCaffeine
//
//  Created by Bastian Bartmann on 10.04.17.
//  Copyright © 2017 Bastian Bartmann. All rights reserved.
//

import AMCoreAudio
import Cocoa

class StatusMenuController: NSObject, DeviceListDelegate {
  let deviceList = DeviceList()
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

    deviceList.delegate = self
    deviceList.populate()

    if deviceList.currentDeviceEnabled() {
      silentAudio.periodicallyPlay()
    }

    NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: DispatchQueue.main)
    NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
  }

  func deviceNamesChanged(oldDeviceNames: [String], newDeviceNames: [String]) {
    let oldCount = oldDeviceNames.count
    let difference = oldCount - newDeviceNames.count

    if difference > 0 {
      for index in 0..<difference {
        statusMenu.removeItem(at: index + startIndex)
      }
    }

    for (index, deviceName) in newDeviceNames.enumerated() {
      if index + 1 <= oldCount {
        let item = statusMenu.item(at: index + startIndex)
        item?.title = deviceName
        item?.state = deviceList.state(for: deviceName)
      } else {
        addDeviceMenuItem(deviceName, position: startIndex + index)
      }
    }
  }

  func addDeviceMenuItem(_ deviceName: String, position: Int) {
    let item = NSMenuItem(title: deviceName, action: #selector(toggleDevice(sender:)), keyEquivalent: "")
    item.target = self
    item.state = deviceList.state(for: deviceName)

    statusMenu.insertItem(item, at: position)
  }

  func toggleDevice(sender: NSMenuItem) {
    deviceList.toggle(sender.title)
  }
}

extension StatusMenuController: EventSubscriber {
  func eventReceiver(_ event: Event) {
    switch event {
    case let event as AudioDeviceEvent:
      switch event {
      case .isJackConnectedDidChange(let device):
        if device.name == "Built-in Output" {
          deviceList.populate()
          startOrStopAudio(device)
        }
      default:
        break
      }
    case let event as AudioHardwareEvent:
      switch event {
      case .defaultOutputDeviceChanged(let device):
        startOrStopAudio(device)
      case .deviceListChanged(_, _):
        deviceList.populate()
      default:
        break
      }
    default:
      break
    }
  }

  func startOrStopAudio(_ device: AudioDevice) {
    if deviceList.enabled(device) {
      silentAudio.periodicallyPlay()
    } else {
      silentAudio.stop()
    }
  }
}
