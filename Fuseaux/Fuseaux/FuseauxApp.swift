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
                .background(TitleBarHiddenWindow())
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}

struct TitleBarHiddenWindow: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.titleVisibility = .visible
                window.titlebarAppearsTransparent = true
                window.standardWindowButton(.closeButton)?.isHidden = false
                window.standardWindowButton(.zoomButton)?.isHidden = false
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
