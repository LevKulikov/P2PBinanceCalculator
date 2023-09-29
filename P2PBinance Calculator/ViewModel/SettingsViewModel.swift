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
    private let dataStorage: DataStorageProtocol
    // Published propertise to identify if some filter must be shown
    @Published var publishedRoleFilterShow: Bool
    @Published var publishedDateRangeFilterShow: Bool
    @Published var publishedAmountFilterShow: Bool
    @Published var publishedAppColor: Color
    // Computed properties
    var ableToAddAccount: Bool {
        getAccounts().count < 5
    }
    
    //MARK: - Initializer
    init(settingsStorage: SettingsStorageProtocol, dataStorage: DataStorageProtocol) {
        self.dataStorage = dataStorage
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
    
    /// Adds new API Account and saves it
    /// - Parameters:
    ///   - name: name of new account
    ///   - apiKey: new account API key
    ///   - secretKey: new account Secret key
    ///   - completionHandler: Completion handler, provides new account if there is success, and nil if it is not
    func addAPIAccount(
        name: String,
        apiKey: String,
        secretKey: String,
        completionHandler: ((APIAccount?) -> Void)?
    ) {
        dataStorage.addAPIAccount(name: name, apiKey: apiKey, secretKey: secretKey, completionHandler: completionHandler)
    }
    
    /// Adds new API Account and saves it
    /// - Parameters:
    ///   - newAccount: New API Account structure
    ///   - completionHandler: Completion handler, provides new account if there is success, and nil if it is not
    func addAPIAccount(_ newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.addAPIAccount(newAccount, completionHandler: completionHandler)
    }
    
    /// Updates existing account to new one
    /// - Parameters:
    ///   - accountToUpdate: previous account
    ///   - newAccount: new account to replace previous
    ///   - completionHandler: Completion handler, provides new account if there is success, and nil if it is not
    func updateAccount(_ accountToUpdate: APIAccount, to newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.updateAccount(accountToUpdate, to: newAccount, completionHandler: completionHandler)
    }
    
    /// Deletes existing account
    /// - Parameters:
    ///   - accountToDelete: Account that should be deleted
    ///   - completionHandler: Completion handler, provides deleted account if there is success, and nil if it is not
    func deleteAccount(_ accountToDelete: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.deleteAccount(accountToDelete, completionHandler: completionHandler)
    }
    
    /// Deletes existing account at specific index
    /// - Parameters:
    ///   - index: index of account to delete
    ///   - completionHandler: Completion handler, provides deleted account if there is success, and nil if it is not
    func deleteAccount(at index: Int, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.deleteAccount(at: index, completionHandler: completionHandler)
    }
    
    /// Provides saved accounts
    /// - Returns: all saved accounts
    func getAccounts() -> [APIAccount] {
        dataStorage.getAccounts()
    }
    
    /// Changes positions of APIAccounts in the array
    /// - Parameters:
    ///   - fromOffsets: set of indexes from what accounts should be moved
    ///   - toOffset: destination of movement
    ///   - completionHandler: Completion handler, provides array of moved accounts if there is success, and nil if it is not
    func moveAccounts(fromOffsets: IndexSet, toOffset: Int, completionHandler: (([APIAccount]?) -> Void)?) {
        dataStorage.moveAccounts(fromOffsets: fromOffsets, toOffset: toOffset, completionHandler: completionHandler)
    }
}
