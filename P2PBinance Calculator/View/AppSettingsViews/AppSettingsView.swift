//
//  AppSettingsView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 27.09.2023.
//

import SwiftUI

struct AppSettingsView: View {
    @State private var selectedSettings: Int?
    
    var body: some View {
        NavigationSplitView {
            List(0..<10, selection: $selectedSettings) { id in
                NavigationLink(value: id) {
                    Text("Settings #\(id)")
                }
            }
        } detail: {
            if let selectedSettings {
                Text("Details of Settings #\(selectedSettings)")
                    .font(.largeTitle)
            } else {
                Text("Setting is not selected")
                    .font(.largeTitle)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

#Preview {
    AppSettingsView()
}
