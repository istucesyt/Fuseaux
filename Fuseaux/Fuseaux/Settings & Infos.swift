import SwiftUI
import AppKit
import Foundation
import WebKit
import ServiceManagement
import Cocoa

struct Settings: View {
    @State private var appVersion = "4.0"
    @AppStorage("newWindowOption") var newWindowOption = true
    
    var body: some View {
        HStack {
            Text("      Commande + W pour fermer.")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary.opacity(0.5))
        }
        .frame(maxWidth: .infinity, maxHeight: 0, alignment: .leading)
        
        VStack {
            Spacer()
            
            Text("Nouvelles fenêtres :")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
            Button(action: {}) {
                Image(systemName: "macwindow.on.rectangle")
                Text("Afficher l'option ")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
                Toggle(isOn: $newWindowOption) {}
                    .tint(Color.accentColor)
                    .toggleStyle(.switch)
                    .controlSize(.mini)
            }
            .buttonStyle(DefaultButtonStyle())
            .cornerRadius(50)
            
            Spacer(minLength: 20)
            
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
            
            Spacer(minLength: 20)
            
            Text("Autres :")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
            Button(action: {
                website()
            }) {
                Image(systemName: "globe")
                Text("istuces.framer.website/fuseaux")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
            }
            .buttonStyle(DefaultButtonStyle())
            .cornerRadius(50)
            Button(action: {
                github()
            }) {
                Image(systemName: "globe")
                Text("github.com/istucesyt/Fuseaux")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
            }
            .buttonStyle(DefaultButtonStyle())
            .cornerRadius(50)
            
            Spacer()
        }
        .frame(minWidth: 400, maxWidth: 400, minHeight: 300, maxHeight: 300)
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
    
    func website() {
        if let url = URL(string: "https://istuces.framer.website/fuseaux") {
            NSWorkspace.shared.open(url)
        }
    }
    
    func github() {
        if let url = URL(string: "https://github.com/istucesyt/Fuseaux") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    Settings()
}
