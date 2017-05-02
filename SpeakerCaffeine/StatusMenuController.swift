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

    silentAudio.periodicallyPlay()

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
      } else {
        addDeviceMenuItem(deviceName, position: startIndex + index)
      }
    }
  }

  func addDeviceMenuItem(_ deviceName: String, position: Int) {
    let item = NSMenuItem(title: deviceName, action: nil, keyEquivalent: "")
    item.target = self

    statusMenu.insertItem(item, at: position)
  }
}

extension StatusMenuController: EventSubscriber {
  func eventReceiver(_ event: Event) {
    switch event {
    case let event as AudioDeviceEvent:
      switch event {
      case .isJackConnectedDidChange(let device):
        deviceList.isJackConnectedDidChange(for: device)
      default:
        break
      }
    case let event as AudioHardwareEvent:
      switch event {
        case .deviceListChanged(_, _):
          deviceList.populate()
        default:
          break
        }
    default:
      break
    }
  }
}
