//
//  AppSettingsView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 27.09.2023.
//

import SwiftUI

struct AppSettingsView: View {
    //MARK: - Properties
    /// ID of selected settings:
    /// * 0 - Accounts settings
    /// * 1 - Filter Settings
    /// * 2 - Dark and Light mode settings
    /// * 3 - Color settings
    @State private var selectedSettingsId: Int?
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    //MARK: - Body
    var body: some View {
        NavigationSplitView {
            settingsList
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
        } detail: {
            selectedSettingsView
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    //MARK: - View properties
    private var noSettingsSelectedView: some View {
        VStack {
            Text("Setting is not selected")
                .font(.largeTitle)
                .foregroundStyle(Color.secondary)
            Text("Please select any setting in the left-hand menu")
                .font(.headline)
                .foregroundStyle(Color.secondary)
        }
    }
    
    @ViewBuilder
    private var selectedSettingsView: some View {
        if let selectedSettingsId {
            
            switch selectedSettingsId {
            case 0:
                SettingsAPIAccountsListView()
            case 1:
                FilterSettingsView()
            default:
                Text("Some error happened, please move back and try again, or reopen app. View ID: \(selectedSettingsId)")
                    .font(.largeTitle)
            }
            
        } else {
            noSettingsSelectedView
        }
    }
    
    private var settingsList: some View {
        List(selection: $selectedSettingsId) {
            p2pOrderListSection
            
            appearanceSection
        }
        .tint(Color(uiColor: .secondarySystemFill))
    }
    
    private var p2pOrderListSection: some View {
        Section("P2P Order list settings") {
            NavigationLink(value: 0) {
                Label() {
                    Text("Accounts")
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "person.circle")
                        .foregroundStyle(SettingsStorage.pickedAppColor)
                }
            }
            
            NavigationLink(value: 1) {
                Label() {
                    Text("Filter settings")
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(SettingsStorage.pickedAppColor)
                }
            }
        }
    }
    
    private var appearanceSection: some View {
        Section("App appearance settings") {
            NavigationLink(value: 2) {
                Label() {
                    Text("Dark and Light modes")
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "circle.righthalf.filled")
                        .foregroundStyle(SettingsStorage.pickedAppColor)
                }
            }
            
            NavigationLink(value: 3) {
                Label() {
                    Text("App appearance")
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "pencil.and.outline")
                        .foregroundStyle(SettingsStorage.pickedAppColor)
                }
            }
        }
    }
    
    //MARK: - Task methods
    
}

#Preview {
    AppSettingsView()
        .environmentObject(SettingsViewModel(
            settingsStorage: SettingsStorageMock(),
            dataStorage: DataStorageMock()
        ))
}
