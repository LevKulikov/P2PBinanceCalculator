//
//  P2PBinance_CalculatorApp.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import SwiftUI

@main
struct P2PBinance_CalculatorApp: App {
    private let persistenceController = PersistenceController.shared
    @ObservedObject private var generalViewModel: GeneralViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel
    
    init() {
        let apiStorage = APIStorage()
        let dataStorage = DataStorage(apiStorage: apiStorage)
        let viewModel = GeneralViewModel(dataStorage: dataStorage)
        generalViewModel = viewModel
        
        let settingsStorage = SettingsStorage()
        let viewModelSettings = SettingsViewModel(settingsStorage: settingsStorage, dataStorage: dataStorage)
        settingsViewModel = viewModelSettings
        
        Self.changeColorOfUIElements(UIColor(SettingsStorage.pickedAppColor))
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                P2POrdersView()
                    .environmentObject(generalViewModel)
                    .environmentObject(settingsViewModel)
                    .tag(0)
                    .tabItem {
                        Label("P2P Orders", systemImage: "list.bullet.below.rectangle")
                    }
                
                AppSettingsView()
                    .environmentObject(settingsViewModel)
                    .tag(1)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            // Need to set settingsViewModel.publishedAppColor to dynamicly change color
            .tint(settingsViewModel.publishedAppColor)
        }
    }
    
    static func changeColorOfUIElements(_ uiColor: UIColor) {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor]
        UIRefreshControl.appearance().tintColor = uiColor
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}
