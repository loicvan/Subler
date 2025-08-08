//
//  ScriptMenuManager.swift
//  Subler
//
//  Created by Loic Vandereyken on 4/2/25.
//

import Foundation
import Cocoa

final class ScriptMenuManager {
	static var ScriptsURL: URL? {
		return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("Subler").appendingPathComponent("Scripts", isDirectory: true)
	}
	static func buildScriptMenu() -> NSMenu? {
		if let url = ScriptMenuManager.ScriptsURL {
			let menu = NSMenu()
			menu.autoenablesItems = false
			if let directoryEnumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.localizedNameKey, URLResourceKey.typeIdentifierKey], options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles], errorHandler: nil) {
				for case let fileURL as URL in directoryEnumerator {
					if let value = try? fileURL.resourceValues(forKeys: [URLResourceKey.typeIdentifierKey]), value.typeIdentifier == "com.apple.applescript.script" {
						if let displayname = try? fileURL.resourceValues(forKeys: [URLResourceKey.localizedNameKey])
						{
							if let displayname = displayname.localizedName {
								let item = menu.addItem(withTitle: displayname, action: #selector(runScript(_:)), keyEquivalent: "")
								item.representedObject = fileURL
								item.target = self
							}
						}
					}
				}
				return menu
			}
		}
		return nil
	}
														
	@objc static func runScript(_ sender: NSMenuItem) {
		var errorDict: NSDictionary? = nil
		let fileURL = sender.representedObject as! URL
		if let scriptObject = NSAppleScript(contentsOf: fileURL, error: nil) {
			if let outputString = scriptObject.executeAndReturnError(&errorDict).stringValue {
				print(outputString)
			} else if (errorDict != nil) {
				print("error: ", errorDict!)
			}
		}
	}

}
