//
//  AppDelegate.swift
//  AutoLauncher
//
//  Created by Lucas Drouot on 20/12/2023.
//

import Cocoa

class AutoLauncherAppDelegate: NSObject, NSApplicationDelegate {

    struct Constants {
        static let mainAppBundleID = "com.istuces.Fuseaux"
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == Constants.mainAppBundleID
        }
        
        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            for _ in 1...4 {
                path = path.deletingLastPathComponent as NSString
            }
            let applicationPathString = path as String
            guard let pathURL = URL(string: applicationPathString) else { return }
            NSWorkspace.shared.openApplication(at: pathURL, configuration:NSWorkspace.OpenConfiguration(), completionHandler: nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}
