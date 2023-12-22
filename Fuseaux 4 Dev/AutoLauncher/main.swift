//
//  main.swift
//  AutoLauncher
//
//  Created by Lucas Drouot on 20/12/2023.
//

import Cocoa

let delegate = AutoLauncherAppDelegate()
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
