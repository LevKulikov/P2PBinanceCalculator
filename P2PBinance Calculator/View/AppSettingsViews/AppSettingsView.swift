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
        case manualAndFeatures
    }
    
    //MARK: - Properties
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.openURL) var openURL
    @State private var selectedSettings: SettingsSection?
    @State private var telegramConfirmationFlag = false
    @State private var emailConfirmationFlag = false
    private let developerTelegramUsername = "k_lev_s"
    private let developerEmail = "levkulikov.appdev@gmail.com"
    
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
            case .manualAndFeatures:
                ManualAndFeaturesListView()
            }
        } else {
            noSettingsSelectedView
        }
    }
    
    private var settingsList: some View {
        List(selection: $selectedSettings) {
            p2pOrderListSection
            
            appearanceSection
            
            //usefulSection
            
            contactsSections
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
    
    private var usefulSection: some View {
        Section("Useful") {
            NavigationLink(value: SettingsSection.manualAndFeatures) {
                Label() {
                    Text("App manual and features")
                        .foregroundStyle(Color.primary)
                } icon: {
                    Image(systemName: "lightbulb.min.fill")
                        .foregroundStyle(SettingsStorage.pickedAppColor)
                }
            }
        }
    }
    
    private var contactsSections: some View {
        Section("Contacts") {
            Label() {
                Text("Developer's Telegram")
            } icon: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(Color("telegramColor"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                telegramConfirmationFlag.toggle()
            }
            .confirmationDialog("@" + developerTelegramUsername, isPresented: $telegramConfirmationFlag, titleVisibility: .visible) {
                Button("Copy username") {
                    copyAsPlainText("@" + developerTelegramUsername)
                }
                
                Link("Send message", destination: URL(string: "https://t.me/" + developerTelegramUsername)!)
            }
            
            Label() {
                Text("Developer's Email")
            } icon: {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(Color("telegramColor"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                emailConfirmationFlag.toggle()
            }
            .confirmationDialog(developerEmail, isPresented: $emailConfirmationFlag, titleVisibility: .visible) {
                Button("Copy email") {
                    copyAsPlainText(developerEmail)
                }
                
                Button("Send mail", action: sendMailToDeveloper)
            }
        }
    }
    
    //MARK: - Task methods
    private func sendMailToDeveloper() {
        let mail = "mailto:" + developerEmail
        guard let mailURL = URL(string: mail) else { return }
        openURL(mailURL)
    }
}

#Preview {
    AppSettingsView()
        .environmentObject(SettingsViewModel(
            settingsStorage: SettingsStorageMock(),
            dataStorage: DataStorageMock()
        ))
}
