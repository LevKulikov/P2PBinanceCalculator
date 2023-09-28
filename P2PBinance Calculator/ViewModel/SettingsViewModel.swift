//
//  SettingsViewModel.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 27.09.2023.
//

import Foundation
import SwiftUI
import Combine


class SettingsViewModel: ObservableObject {
    //MARK: - Properties
    /// Storage for settings to store it in memory
    private let settingsStorage: SettingsStorageProtocol
    // Published propertise to identify if some filter must be shown
    @Published var publishedRoleFilterShow: Bool
    @Published var publishedDateRangeFilterShow: Bool
    @Published var publishedAmountFilterShow: Bool
    @Published var publishedAppColor: Color
    
    //MARK: - Initializer
    init(settingsStorage: SettingsStorageProtocol) {
        self.settingsStorage = settingsStorage
        publishedRoleFilterShow = settingsStorage.savedRoleFilterShow
        publishedDateRangeFilterShow = settingsStorage.savedDateRangeFilterShow
        publishedAmountFilterShow = settingsStorage.savedAmountFilterShow
        publishedAppColor = SettingsStorage.pickedAppColor
    }
    
    //MARK: - Methods
    /// Saves if role filter should be show or not
    /// - Parameter show: set if the filter should be shown or not
    func saveRoleFilter(show: Bool) {
        settingsStorage.setRoleFilter(show: show)
        publishedRoleFilterShow = show
    }
    
    /// Saves if date range filter should be show or not
    /// - Parameter show: set if the filter should be shown or not
    func saveDateRangeFilter(show: Bool) {
        settingsStorage.setDateRangeFilter(show: show)
        publishedDateRangeFilterShow = show
    }
    
    /// Saves if amount filter should be show or not
    /// - Parameter show: set if the filter should be shown or not
    func saveAmounteFilter(show: Bool) {
        settingsStorage.setAmountFilter(show: show)
        publishedAmountFilterShow = show
    }
    
    /// Saves app color to display
    /// - Parameter color: color to save
    func setAppColor(_ color: Color) {
        settingsStorage.setAppColor(color)
        publishedAppColor = color
        P2PBinance_CalculatorApp.changeColorOfUIElements(UIColor(color))
    }
}
