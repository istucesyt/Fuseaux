import SwiftUI
import AppKit
import Foundation
import WebKit
import ServiceManagement
import Cocoa

struct ContentView: View {
    @State private var searchQuery = ""
    @State private var currentTime = Date()
    @State private var statusItem: NSStatusItem?
    @State private var timer: Timer?
    @State private var gmtOffset = ""
    let applicationBundleIdentifier = "com.apple.ScriptEditor.id.Fuseaux-Utility"
    @AppStorage("isExpandedSearch") private var isExpandedSearch = true
    @AppStorage("isExpandedOptions") private var isExpandedOptions = true
    @AppStorage("selectedTimeZone") var selectedTimeZone: String?
    @AppStorage("showSeconds") private var showSeconds = false
    @AppStorage("showGMT") private var showGMT = false
    @AppStorage("hourFormat") private var hourFormat = 12
    @AppStorage("navigationTitle") private var navigationTitle = "Fuseaux"
    @AppStorage("customNavigationTitle") private var customNavigationTitle = false
    
    private let pasteboard = NSPasteboard.general
    
    private var filteredTimeZones: [String] {
        if searchQuery.isEmpty {
            return TimeZone.knownTimeZoneIdentifiers
        } else {
            return TimeZone.knownTimeZoneIdentifiers.filter { $0.localizedCaseInsensitiveContains(searchQuery) }
        }
    }

    var body: some View {
        HStack {
            VStack {
                DisclosureGroup("Rechercher", isExpanded: $isExpandedSearch) {
                    if isExpandedSearch {
                        ScrollView {
                            SearchBar(text: $searchQuery)
                                .padding(3)
                        }
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.primary.colorInvert().opacity(0.5))
                .cornerRadius(15)
                
                VStack {
                    List(selection: $selectedTimeZone) {
                        Section(header: Text("🌍 Fuseaux")) {
                            ForEach(filteredTimeZones, id: \.self) { timeZoneIdentifier in
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text(timeZoneIdentifier)
                                            .font(.headline)
                                    }
                                    if let selectedTimeZone = selectedTimeZone, selectedTimeZone == timeZoneIdentifier {
                                        VStack {
                                            Text("Fuseau horaire sélectionné. Heure chargée.")
                                                .font(.caption)
                                        }
                                    }
                                }
                                .tag(timeZoneIdentifier)
                            }
                        }
                    }
                    .listStyle(DefaultListStyle())
                    .padding(3)
                }
                .cornerRadius(20)
                
                Button(action: {
                    Settings().openInWindowS(title: "Paramètres et infos", sender: self)
                }) {
                    Image(systemName: "circle.hexagonpath")
                    Text("Paramètres et infos")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.primary)
                }
                .buttonStyle(DefaultButtonStyle())
                .cornerRadius(50)
            }
            
            VStack{
                VStack(spacing: 15) {
                    if let selectedTimeZone = selectedTimeZone {
                        VStack {
                            Text(getCurrentTime(for: selectedTimeZone ))
                                .font(.system(size: 40, weight: .bold))
                                .onAppear {
                                    startTimer()
                            }
                            
                            if showGMT {
                                Text("GMT / UTC \(getTimeZoneOffset(for: selectedTimeZone))")
                                    .font(.system(size: 14))
                            }
                        }
                        .padding()
                        .background(Color.primary.colorInvert())
                        .cornerRadius(10)
                        
                        DisclosureGroup("Options", isExpanded: $isExpandedOptions) {
                            if isExpandedOptions {
                                VStack {
                                    Spacer()
                                    
                                    VStack {
                                        VStack {
                                            Button(action: {
                                                copyToClipboard()
                                            }) {
                                                Image(systemName: "doc.on.doc")
                                                Text("Partager ")
                                                    .font(.system(size: 12, weight: .regular))
                                                    .foregroundColor(.primary)
                                            }
                                            .buttonStyle(DefaultButtonStyle())
                                            .cornerRadius(50)
                                            
                                            VStack {
                                                if showGMT {
                                                    Text("Actuellemment, il est \(getCurrentTime(for: selectedTimeZone)) dans le fuseau horaire \(selectedTimeZone) (GMT \(getTimeZoneOffset(for: selectedTimeZone))).")
                                                        .font(.system(size: 12, weight: .regular))
                                                        .foregroundColor(Color.white)
                                                        .padding()
                                                } else {
                                                    Text("Actuellemment, il est \(getCurrentTime(for: selectedTimeZone)) dans le fuseau horaire \(selectedTimeZone).")
                                                        .font(.system(size: 12, weight: .regular))
                                                        .foregroundColor(Color.white)
                                                        .padding()
                                                }
                                            }
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                        }
                                        .padding()
                                    }
                                    .background(Color.primary.opacity(0.05))
                                    .cornerRadius(10)
                                    
                                    Spacer(minLength: 30)
                                    
                                    Toggle("Afficher les secondes", isOn: $showSeconds)
                                        .font(.system(size: 12, weight: .regular))
                                        .padding(3)
                                        .onChange(of: showSeconds, perform: { _ in
                                            currentTime = Date()
                                        })
                                        .frame(alignment: .leading)
                                    
                                    VStack {
                                        Toggle("Afficher la valeur GMT (UTC)", isOn: $showGMT)
                                            .font(.system(size: 12, weight: .regular))
                                            .padding(3)
                                            .frame(alignment: .leading)
                                        Text("Greenwich Mean Time\n\n")
                                            .font(.system(size: 9, weight: .regular))
                                            .frame(alignment: .leading)
                                    }
                                    
                                    Picker("Format d'heure", selection: $hourFormat) {
                                        Text("12 heures").tag(12)
                                            .font(.system(size: 12, weight: .regular))
                                        Text("24 heures").tag(24)
                                            .font(.system(size: 12, weight: .regular))
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding(20)
                                    .onChange(of: hourFormat, perform: { _ in
                                        currentTime = Date()
                                    })
                                    
                                    Spacer()
                                }
                                .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.primary.colorInvert().opacity(0.5))
                        .cornerRadius(15)
                        
                    } else {
                        
                        HStack {
                            Spacer(minLength: 30)
                            
                            Image("IconA")
                                .resizable()
                                .scaledToFit()
                            Image("IconAB")
                                .resizable()
                                .scaledToFit()
                            Image("IconB")
                                .resizable()
                                .scaledToFit()
                            
                            Spacer(minLength: 30)
                        }
                        .padding(20)
                        .frame(maxWidth: 400)
                        
                        VStack{
                            VStack {
                                Text("Aucun fuseau horaire n'est sélectionné...\nPour commencer, veuillez sélectionner un fuseau horaire dans la liste ci-dessous ou en utilisant la barre de recherche.")
                                    .font(.system(size: 12, weight: .regular))
                                
                                Spacer(minLength: 20)
                                
                                Image("Tuto3")
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                            }
                            .padding(20)
                        }
                        .background(Color.primary.colorInvert().opacity(0.5))
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        hideMainWindow()
                    }) {
                        Image(systemName: "eye.slash")
                        Text("Masquer l'application")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(DefaultButtonStyle())
                    .cornerRadius(50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    currentTime = Date()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .padding(20)
        
        Spacer()
        
        Button(action: {
            SecContentView().openInWindow(title: "Fuseaux (secondaire)", sender: self)
        }) {
            Image(systemName: "plus")
            Text("Ajouter une comparaison")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.primary)
        }
        .buttonStyle(DefaultButtonStyle())
        .cornerRadius(50)
        
        Spacer(minLength: 15)
    }
    
//    func isApplicationInstalled(bundleIdentifier: String) -> Bool {
//        if let _ = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
//            return true
//        } else {
//            return false
//        }
//    }

//    func launchApplication(bundleIdentifier: String) {
//        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
//            let configuration = NSWorkspace.OpenConfiguration()
//            NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, _ in
//            }
//        }
//    }
    
    func copyToClipboard() {
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        
        if showGMT {
            pasteboard.setString("Actuellemment, il est \(getCurrentTime(for: selectedTimeZone! )) dans le fuseau horaire \(selectedTimeZone! ) (GMT \(getTimeZoneOffset(for: selectedTimeZone! ))).\nGénéré par Fuseaux 4 : https://istuces.framer.website/fuseaux", forType: .string)
        } else {
            pasteboard.setString("Actuellemment, il est \(getCurrentTime(for: selectedTimeZone! )) dans le fuseau horaire \(selectedTimeZone! ).\nGénéré par Fuseaux 4 : https://istuces.framer.website/fuseaux", forType: .string)
        }
    }
    
    func hideMainWindow() {
        NSApplication.shared.hide(nil)
    }

    func getCurrentTime(for timeZoneIdentifier: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        
        if showSeconds {
            formatter.dateFormat = hourFormat == 12 ? "hh:mm:ss a" : "HH:mm:ss"
        } else {
            formatter.dateFormat = hourFormat == 12 ? "hh:mm a" : "HH:mm"
        }
        
        return formatter.string(from: currentTime)
    }

    func getTimeZoneOffset(for timeZoneIdentifier: String) -> String {
        let timeZone = TimeZone(identifier: timeZoneIdentifier)
        let offset = timeZone?.secondsFromGMT() ?? 0
        
        let sign = offset >= 0 ? "+" : "-"
        let hours = abs(offset) / 3600
        let minutes = (abs(offset) / 60) % 60
        
        return String(format: "\(sign)%02d:%02d", hours, minutes)
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            currentTime = Date()
        }
    }
}

extension View {
    @discardableResult
    func openInWindow(title: String, sender: Any?) -> NSWindow {
        let controller = NSHostingController(rootView: self)
        let win = NSWindow(contentViewController: controller)
        win.contentViewController = controller
        win.title = title
        win.makeKeyAndOrderFront(sender)
        win.titleVisibility = .visible
        win.titlebarAppearsTransparent = true
        win.standardWindowButton(.closeButton)?.isHidden = false
        win.standardWindowButton(.zoomButton)?.isHidden = false
        win.standardWindowButton(.miniaturizeButton)?.isHidden = true
        return win
    }
}

extension View {
    @discardableResult
    func openInWindowS(title: String, sender: Any?) -> NSWindow {
        let controller = NSHostingController(rootView: self)
        let win = NSWindow(contentViewController: controller)
        win.contentViewController = controller
        win.title = title
        win.makeKeyAndOrderFront(sender)
        win.titleVisibility = .visible
        win.titlebarAppearsTransparent = true
        win.standardWindowButton(.closeButton)?.isHidden = false
        win.standardWindowButton(.zoomButton)?.isHidden = true
        win.standardWindowButton(.miniaturizeButton)?.isHidden = true
        return win
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Rechercher", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct Settings: View {
    @State private var appVersion = "4.0-dev5"
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Lancer automatiquement au démarrage :")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
            VStack {
                HStack {
                    VStack {
                        Image("Tuto1")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                        Text("1")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    VStack {
                        Image("Tuto2")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                        Text("2")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                Text("Afin de permettre à Fuseaux de se lancer automatiquement au démarrage, effectuez un clic-droit sur son icône dans le Dock (1), survolez ''Options'' puis sélectionnez ''Ouvrir avec la session'' (2).")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.primary)
            }
            
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
            
            Spacer()
        }
        .frame(minWidth: 400, minHeight: 350)
        .padding(20)
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

#Preview {
    ContentView()
}

#Preview {
    Settings()
}

