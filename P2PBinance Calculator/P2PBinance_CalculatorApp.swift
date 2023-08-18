//
//  P2PBinance_CalculatorApp.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import SwiftUI

@main
struct P2PBinance_CalculatorApp: App {
    let persistenceController = PersistenceController.shared
    var generalViewModel: GeneralViewModel {
        let apiStorage = APIStorage()
        let dataStorage = DataStorage(apiStorage: apiStorage)
        let viewModel = GeneralViewModel(dataStorage: dataStorage)
        return viewModel
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(/*GeneralViewModelMock() as*/ generalViewModel)

        }
    }
}
