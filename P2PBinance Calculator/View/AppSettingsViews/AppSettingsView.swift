//
//  AppSettingsView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 27.09.2023.
//

import SwiftUI

struct AppSettingsView: View {
    enum SettingsSection {
        case accountsSettings
        case filterSettings
        case colorSchemeSettings
        case appearanceSettings
    }
    //MARK: - Properties
    @State private var selectedSettings: SettingsSection?
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
        if let selectedSettings {
            
            switch selectedSettings {
            case .accountsSettings:
                SettingsAPIAccountsListView()
            case .filterSettings:
                FilterSettingsView()
            case .colorSchemeSettings:
                ColorModeView()
            case .appearanceSettings:
                AppAppearanceView()
            }
            
        } else {
            noSettingsSelectedView
        }
    }
    
    private var settingsList: some View {
        List(selection: $selectedSettings) {
            p2pOrderListSection
            
            appearanceSection
        }
        .tint(Color(uiColor: .secondarySystemFill))
    }
    
    private var p2pOrderListSection: some View {
        Section("P2P Order list settings") {
            NavigationLink(value: SettingsSection.accountsSettings) {
                Label() {
                    Text("Accounts")
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "person.circle")
                        .foregroundStyle(SettingsStorage.pickedAppColor)
                }
            }
            
            NavigationLink(value: SettingsSection.filterSettings) {
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
            NavigationLink(value: SettingsSection.colorSchemeSettings) {
                Label() {
                    Text("Dark and Light modes")
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "circle.righthalf.filled")
                        .foregroundStyle(SettingsStorage.pickedAppColor)
                }
            }
            
            NavigationLink(value: SettingsSection.appearanceSettings) {
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
