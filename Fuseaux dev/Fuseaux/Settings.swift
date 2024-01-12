import SwiftUI
import AppKit
import Foundation
import WebKit
import ServiceManagement
import Cocoa

struct Settings: View {
    @State private var appVersion = "4.0-dev6"
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Mise à jour :")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
            Button(action: {
                update()
            }) {
                Image(systemName: "checkmark.icloud")
                Text("Vérifier les MàJs ")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
            }
            .buttonStyle(DefaultButtonStyle())
            .cornerRadius(50)
            Text("Vous utilisez la version")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.primary)
            +
            Text(" \(appVersion)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer(minLength: 20)
            
            Text("Discord :")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
            Button(action: {
                discord()
            }) {
                Image(systemName: "command")
                Text("Rejoindre le serveur ")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
            }
            .buttonStyle(DefaultButtonStyle())
            .cornerRadius(50)
            
            Spacer()
        }
        .frame(minWidth: 400, maxWidth: 400, minHeight: 150, maxHeight: 150)
        .padding(20)
        .fixedSize()
    }
    
    func update() {
        if let url = URL(string: "https://github.com/istucesyt/Fuseaux/releases") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func discord() {
        if let url = URL(string: "https://tinyurl.com/iTech-Discord") {
            NSWorkspace.shared.open(url)
        }
    }
}
