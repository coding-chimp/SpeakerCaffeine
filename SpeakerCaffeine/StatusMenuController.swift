//
//  StatusMenuController.swift
//  SpeakerCaffeine
//
//  Created by Bastian Bartmann on 10.04.17.
//  Copyright © 2017 Bastian Bartmann. All rights reserved.
//

import AMCoreAudio
import Cocoa
import ServiceManagement

class StatusMenuController: NSObject, DeviceListDelegate {
  let aboutWindow = AboutWindow()
  let defaults = UserDefaults.standard
  let deviceList = DeviceList()
  let silentAudio = SilentAudio()
  var startAtLogin = false
  let startIndex = 1
  let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  var statusButton: NSStatusBarButton?

  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var startAtLoginItem: NSMenuItem!

  @IBAction func toggleStartAtLogin(_ sender: Any) {
    startAtLogin = !startAtLogin
    setStartAtLoginItemState()
    setLoginItem()
  }
  
  @IBAction func aboutClicked(_ sender: Any) {
    aboutWindow.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  @IBAction func quitClicked(_ sender: Any) {
    NSApplication.shared().terminate(self)
  }
  
  override func awakeFromNib() {
    statusButton = statusItem.button
    let icon = NSImage(named: "StatusIcon")
    icon?.isTemplate = true
    statusButton?.image = icon
    statusItem.menu = statusMenu

    startAtLogin = defaults.bool(forKey: "startAtLogin")
    setStartAtLoginItemState()

    deviceList.delegate = self
    deviceList.populate()

    startOrStopAudio()

    NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: DispatchQueue.main)
    NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
  }

  func startOrStopAudio() {
    let currentDevice = AudioDevice.defaultOutputDevice()

    startOrStopAudio(currentDevice)
  }

  func startOrStopAudio(_ device: AudioDevice?) {
    if let device = device, deviceList.enabled(device) {
      statusButton?.appearsDisabled = false
      silentAudio.periodicallyPlay()
    } else {
      statusButton?.appearsDisabled = true
      silentAudio.stop()
    }
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

  private func setStartAtLoginItemState() {
    if startAtLogin {
      startAtLoginItem.state = NSOnState
    } else {
      startAtLoginItem.state = NSOffState
    }
  }

  private func setLoginItem() {
    let helperAppIdentifier = "org.code-chimp.SpeakerCaffeine-Helper"
    defaults.set(startAtLogin, forKey: "startAtLogin")
    SMLoginItemSetEnabled(helperAppIdentifier as CFString, startAtLogin)
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
}
