import SwiftUI
import AppKit
import Foundation
import WebKit
import ServiceManagement
import Cocoa

struct ContentView: View {
    private struct Constants {
        static let helperBundleID = "com.istuces.AutoLauncher"
    }
    
    @State private var searchQuery = ""
    @State private var currentTime = Date()
    @State private var showSeconds = false
    @State private var showGMT = false
    @State private var hourFormat = 12
    @State private var showMenuBarTime = false
    @State private var statusItem: NSStatusItem?
    @State private var timer: Timer?
    @State private var gmtOffset = ""
    @State private var isDisplayedInStatusBar = false
    let applicationBundleIdentifier = "com.apple.ScriptEditor.id.Fuseaux-Utility"
    @State private var isExpandedSearch = true
    @State private var isExpandedOptions = true
    @State private var isExpandedLaunchAS = false
    @AppStorage("selectedTimeZone") var selectedTimeZone: String?
    @AppStorage("LaunchAtLogin") private var LaunchAtLogin = false {
        didSet {
            SMLoginItemSetEnabled(Constants.helperBundleID as CFString, LaunchAtLogin)
        }
    }
    
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
                DisclosureGroup("Lancer au démarrage", isExpanded: $isExpandedLaunchAS) {
                    if isExpandedLaunchAS {
                        VStack {
                            Toggle(isOn: $LaunchAtLogin) {
                                Text("Activer/Désactiver")
                            }
                            .toggleStyle(.switch)
                            .padding(10)
                        }
                        .padding(.leading)
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color.blue.opacity(0.3))
                .cornerRadius(15)
                
                Spacer()
                
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
            }
            
            VStack{
                VStack(spacing: 15) {
                    if let selectedTimeZone = selectedTimeZone {
                        VStack {
                            if showMenuBarTime {
                                Text("Heure du fuseau :")
                                    .font(.system(size: 16, weight: .bold))
                                Text(getCurrentTime(for: selectedTimeZone))
                                    .font(.system(size: 16, weight: .regular))
                                    .onAppear {
                                        setupMenuBarTime()
                                    }
                                Text("(affichée dans la barre d'état)")
                                    .font(.system(size: 13, weight: .bold))
                            } else {
                                VStack {
                                    Text("Heure du fuseau :")
                                        .font(.system(size: 20, weight: .bold))
                                    Text(getCurrentTime(for: selectedTimeZone ))
                                        .font(.system(size: 40, weight: .bold))
                                        .onAppear {
                                            startTimer()
                                        }
                                }
                            }
                            
                            if showGMT {
                                Text("GMT \(getTimeZoneOffset(for: selectedTimeZone))")
                                    .font(.system(size: 14))
                            }
                        }
                        .padding()
                        .cornerRadius(10)
                        
                        DisclosureGroup("Options", isExpanded: $isExpandedOptions) {
                            if isExpandedOptions {
                                VStack {
                                    Spacer()
                                    
                                    Toggle("Afficher les secondes", isOn: $showSeconds)
                                        .font(.system(size: 12, weight: .regular))
                                        .padding(3)
                                        .onChange(of: showSeconds, perform: { _ in
                                            currentTime = Date()
                                        })
                                        .frame(alignment: .leading)
                                    
                                    VStack {
                                        Toggle("Afficher la valeur GMT", isOn: $showGMT)
                                            .font(.system(size: 12, weight: .regular))
                                            .padding(3)
                                            .frame(alignment: .leading)
                                        Text("Greenwich Mean Time\n\n")
                                            .font(.system(size: 9, weight: .regular))
                                            .frame(alignment: .leading)
                                    }
                                    
                                    VStack {
                                        Toggle("Afficher l'heure dans la barre d'état", isOn: $showMenuBarTime)
                                            .font(.system(size: 12, weight: .regular))
                                            .padding(3)
                                            .frame(alignment: .leading)
                                            .onChange(of: showMenuBarTime, perform: { _ in
                                                if showMenuBarTime {
                                                    setupMenuBarTime()
                                                } else {
                                                    removeMenuBarTime()
                                                }
                                            })
                                        Text("Fonctionne de manière optimale avec le lancement au démarrage.")
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
                                    
                                    Button(action: {

                                    }) {
                                        Image(systemName: "pencil")
                                        Text("Définir comme fuseau système : indisponible")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.primary)
                                    }
                                    .buttonStyle(DefaultButtonStyle())
                                    .cornerRadius(50)
                                    .disabled(true)
                                    
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
                        
                        VStack{
                            Text("Aucun fuseau horaire n'est sélectionné...\nPour commencer, veuillez sélectionner un fuseau horaire dans la liste ci-dessous ou en utilisant la barre de recherche.")
                                .font(.system(size: 12, weight: .regular))
                                .padding(40)
                        }
                        .background(Color.primary.colorInvert().opacity(0.6))
                        .cornerRadius(10)
                    }
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
        .frame(minWidth: 600, minHeight: 550)
        .padding(20)
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
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    func setupMenuBarTime() {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            if let button = statusItem?.button {
                button.image = NSImage(systemSymbolName: "globe.asia.australia.fill", accessibilityDescription: "Fuseaux")
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    button.title = ("\(selectedTimeZone ?? "") : \(getCurrentTime(for: selectedTimeZone ?? ""))")
                    gmtOffset = getTimeZoneOffset(for: selectedTimeZone ?? "")
                }
            }
        }

       func removeMenuBarTime() {
           if let statusItem = statusItem {
               timer?.invalidate()
               NSStatusBar.system.removeStatusItem(statusItem)
               self.statusItem = nil
           }
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

#Preview {
    ContentView()
}
