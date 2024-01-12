//
//  FuseauxApp.swift
//  Fuseaux
//
//  Created by iStuces on 09/06/2023.
//

import SwiftUI
import AppKit
import Foundation
import WebKit
import ServiceManagement
import Cocoa

@main
struct FuseauxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(TitleBarWindowStyle())
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
    }
}

struct TitleBarWindowStyle: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.titleVisibility = .hidden
                window.titlebarAppearsTransparent = true
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
