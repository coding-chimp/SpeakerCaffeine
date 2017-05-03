//
//  AppDelegate.swift
//  SpeakerCaffeine Helper
//
//  Created by Bastian Bartmann on 03.05.17.
//  Copyright © 2017 Bastian Bartmann. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let appIdentifier = "org.code-chimp.SpeakerCaffeine"
    var aldreadyRunning = false

    for app in NSWorkspace.shared().runningApplications {
      if app.bundleIdentifier == appIdentifier {
        aldreadyRunning = true
        break
      }
    }

    if !aldreadyRunning {
      startApp()
    }

    terminate()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func startApp() {
    let path = Bundle.main.bundlePath as NSString
    var components = path.pathComponents
    components.removeLast()
    components.removeLast()
    components.removeLast()
    components.removeLast()

    let newPath = NSString.path(withComponents: components) as String

    NSWorkspace.shared().launchApplication(newPath)
  }

  func terminate() {
    NSApp.terminate(nil)
  }

}
