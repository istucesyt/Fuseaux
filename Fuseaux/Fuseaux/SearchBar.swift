import SwiftUI
import AppKit
import Foundation
import WebKit
import ServiceManagement
import Cocoa

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
