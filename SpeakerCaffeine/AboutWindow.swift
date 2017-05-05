//
//  AboutWindow.swift
//  SpeakerCaffeine
//
//  Created by Bastian Bartmann on 05.05.17.
//  Copyright © 2017 Bastian Bartmann. All rights reserved.
//

import Cocoa

class AboutWindow: NSWindowController {

  @IBOutlet weak var versionField: NSTextField!
  @IBOutlet weak var weblinkButton: NSButtonCell!

  @IBAction func weblinkClicked(_ sender: Any) {
    if let url = URL(string: "https://code-chimp.org/apps") {
      NSWorkspace.shared().open(url)
    }
  }

  override var windowNibName : String! {
    return "AboutWindow"
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    self.window?.center()
    self.window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    setVersion()
    styleWeblink()
  }

  private func setVersion() {
    if let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String, let build = dictionary["CFBundleVersion"] as? String {
      versionField.stringValue = "Version \(version) (\(build))"
    }
  }

  private func styleWeblink() {
    let style = NSMutableParagraphStyle()
    style.alignment = .center

    let font = NSFont.systemFont(ofSize: 11)

    let linkAttributes: [String: Any] = [
      NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
      NSParagraphStyleAttributeName: style,
      NSForegroundColorAttributeName: NSColor.blue,
      NSFontAttributeName: font
    ]
    let underlineAttributedString = NSAttributedString(string: "code-chimp.org/apps", attributes: linkAttributes)

    weblinkButton.attributedTitle = underlineAttributedString
  }

}
