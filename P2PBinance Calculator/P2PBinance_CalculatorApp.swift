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
    private let generalViewModel: GeneralViewModel
    private let settingsViewModel: SettingsViewModel
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "binanceColor")!]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "binanceColor")!]
        UIRefreshControl.appearance().tintColor = UIColor(named: "binanceColor")
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        let apiStorage = APIStorage()
        let dataStorage = DataStorage(apiStorage: apiStorage)
        let viewModel = GeneralViewModel(dataStorage: dataStorage)
        generalViewModel = viewModel
        
        let settingsStorage = SettingsStorage()
        let viewModelSettings = SettingsViewModel(settingsStorage: settingsStorage)
        settingsViewModel = viewModelSettings
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
            .tint(Color("binanceColor"))
        }
    }
}
