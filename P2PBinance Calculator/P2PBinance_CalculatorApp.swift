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
    
    init() {
        let apiStorage = APIStorage()
        let dataStorage = DataStorage(apiStorage: apiStorage)
        let viewModel = GeneralViewModel(dataStorage: dataStorage)
        generalViewModel = viewModel
    }

    var body: some Scene {
        WindowGroup {
            P2POrdersView()
                .environmentObject(generalViewModel)

        }
    }
}
