//
//  FuseauxApp.swift
//  Fuseaux
//
//  Created by Lucas Drouot on 09/06/2023.
//

import SwiftUI
import AppKit
import Foundation
import WebKit
import ServiceManagement
import Cocoa

@main
struct FuseauxApp: App {
    @State private var showAlert = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if showAlert {
                        showAlert = false
                        showCustomAlert()
                    }
                }
        }
    }

    func showCustomAlert() {
        let alert = NSAlert()
        alert.messageText = "Bienvenue dans Fuseaux !\n\nCommentaire sur l'utilisation :"
        alert.alertStyle = .warning
        alert.informativeText = "Fuseaux est et sera toujours gratuit.\nJ'espère que vous apprécierez l'application !"
        alert.addButton(withTitle: "C'est compris !")

        DispatchQueue.main.async {
            alert.runModal()
        }
    }
}
