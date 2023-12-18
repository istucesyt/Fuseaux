import SwiftUI
import AppKit
import Foundation
import WebKit
import ServiceManagement
import Cocoa

struct ContentView: View {
    @State private var searchQuery = ""
    @State private var selectedTimeZone: String?
    @State private var currentTime = Date()
    @State private var showSeconds = false
    @State private var showGMT = false
    @State private var hourFormat = 12
    @State private var showMenuBarTime = false
    @State private var statusItem: NSStatusItem?
    @State private var timer: Timer?
    @State private var gmtOffset = ""
    @State private var isDisplayedInStatusBar = false
    @State private var macOSVersion = ""
    @State private var showWebPage = false
    @State private var showAlert = true
    let applicationBundleIdentifier = "com.apple.ScriptEditor.id.Fuseaux-Utility"
    @State private var isExpanded1 = true
    @State private var isExpanded2 = true

    private var filteredTimeZones: [String] {
        if searchQuery.isEmpty {
            return TimeZone.knownTimeZoneIdentifiers
        } else {
            return TimeZone.knownTimeZoneIdentifiers.filter { $0.localizedCaseInsensitiveContains(searchQuery) }
        }
    }

    var body: some View {
        Spacer()
        
        ScrollView {
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
                        
                        DisclosureGroup("Options", isExpanded: $isExpanded1) {
                            if isExpanded1 {
                                VStack {
                                    Spacer()
                                    
                                    Toggle("Afficher les secondes", isOn: $showSeconds)
                                        .font(.system(size: 12, weight: .regular))
                                        .padding(3)
                                        .onChange(of: showSeconds, perform: { _ in
                                            currentTime = Date()
                                        })
                                        .frame(alignment: .leading)
                                    
                                    Toggle("Afficher la valeur GMT\n", isOn: $showGMT)
                                        .font(.system(size: 12, weight: .regular))
                                        .padding(3)
                                        .frame(alignment: .leading)
                                    
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
                                        showConfirmationAlert()
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.primary)
                                        Text("Définir comme fuseau système")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(.primary)
                                    }
                                    .buttonStyle(DefaultButtonStyle())
                                    .frame(maxWidth: .infinity)
                                    
                                    Spacer()
                                }
                                .background(Color.primary.colorInvert().opacity(0.5))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.primary.colorInvert())
                        .cornerRadius(10)
                        
                    } else {
                        
                        VStack{
                            Text("Aucun fuseau horaire n'est sélectionné...\nPour commencer, veuillez sélectionner un fuseau horaire dans la liste ci-dessous ou en utilisant la barre de recherche.")
                                .font(.system(size: 12, weight: .bold))
                                .fontWeight(.bold)
                                .padding(10)
                        }
                        .background(Color.primary.colorInvert().opacity(0.6))
                        .cornerRadius(10)
                    }
                    
                    DisclosureGroup("Rechercher", isExpanded: $isExpanded2) {
                        if isExpanded2 {
                            ScrollView {
                                SearchBar(text: $searchQuery)
                                    .padding(3)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.primary.colorInvert())
                    .cornerRadius(10)
                    
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
                    .listStyle(InsetListStyle())
                    .padding(3)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    currentTime = Date()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)
            }
            .frame(minWidth: 300, minHeight: 1500)
        }
        .frame(minWidth: 300, minHeight: 550)
    }
    
    func showConfirmationAlert() {
        let alert = NSAlert()
        alert.messageText = "Souhaitez-vous continuer ?"
        alert.informativeText = "Fuseaux va vérifier la présence de l'utilitaire et le lancer si celui-ci est trouvé.\nDans le cas inverse, il vous sera proposé de l'installer."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Continuer")
        alert.addButton(withTitle: "Annuler")
        
        let response1 = alert.runModal()
        
        if response1 == .alertFirstButtonReturn {

            if isApplicationInstalled(bundleIdentifier: applicationBundleIdentifier) {
                let alert = NSAlert()
                alert.messageText = "Utilitaire prêt.\n\n⚠️ Information :"
                alert.informativeText = "Vous devrez confirmer le fuseau horaire que vous souhaitez utiliser comme fuseau système (sélection d'un item de la liste)."
                alert.addButton(withTitle: "Continuer")

                let response3 = alert.runModal()
                
                if response3 == .alertFirstButtonReturn {
                    launchApplication(bundleIdentifier: applicationBundleIdentifier)
                }
            } else {
                let alert = NSAlert()
                alert.messageText = "L'application n'est pas installée..."
                alert.informativeText = "Souhaitez-vous installer l'utilitaire ?"
                alert.addButton(withTitle: "Installer l'utilitaire")
                alert.addButton(withTitle: "Non, abandonner")
                
                let response2 = alert.runModal()

                if response2 == .alertFirstButtonReturn {
                    if let url = URL(string: "https://github.com/istucesyt/Fuseaux/releases/tag/v1.0-build1_utility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
    
    func isApplicationInstalled(bundleIdentifier: String) -> Bool {
        if let _ = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return true
        } else {
            return false
        }
    }

    func launchApplication(bundleIdentifier: String) {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, _ in
            }
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
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    func getMacOSVersion() -> String {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            return versionString
        }
    
    func setupMenuBarTime() {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            if let button = statusItem?.button {
                button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
