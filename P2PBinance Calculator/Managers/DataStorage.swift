//
//  DataStorage.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 11.08.2023.
//

import Foundation

/// Protocol for object that stores app data
protocol DataStorageProtocol: AnyObject, APIStorageProtocol {
    /// Saves new fiat filter
    /// - Parameter newFiatFilter: New fiat filter set by user
    func setFiatFilter(for newFiatFilter: C2CHistoryResponse.C2COrderFiat)
    
    /// Provides previously saved fiat filter
    /// - Returns: Saved fiat filter
    func getFiatFilter() -> C2CHistoryResponse.C2COrderFiat
    
    /// Saves new custom fiat filter name
    /// - Parameter newCustomFiat: New custom fiat filter name set by user
    func setCustomFiatFilter(for newCustomFiat: String)
    
    /// Provides previously saved custom fiat filter name
    /// - Returns: Saved custom fiat filter name
    func getCustomFiatFilter() -> String
}

/// Object that stores app data
final class DataStorage: DataStorageProtocol {
    //MARK: Properties
    private let apiStorage: APIStorageProtocol
    /// Saved fiat filter set by user previously
    private var fiatFilter: C2CHistoryResponse.C2COrderFiat
    private var customFiatFilter: String
    private let userDefaultsFiatFilterKey = "userDefaultsFiatFilterKey"
    private let userDefaultsCustomFiatFilterKey = "userDefaultsCustomFiatFilterKey"
    
    //MARK: Initializer
    init(apiStorage: APIStorageProtocol) {
        self.apiStorage = apiStorage
        let fiatRawValue = UserDefaults.standard.string(forKey: userDefaultsFiatFilterKey) ?? C2CHistoryResponse.C2COrderFiat.allFiat.rawValue
        fiatFilter = C2CHistoryResponse.C2COrderFiat(rawValue: fiatRawValue) ?? C2CHistoryResponse.C2COrderFiat.allFiat
        customFiatFilter = UserDefaults.standard.string(forKey: userDefaultsCustomFiatFilterKey) ?? ""
    }
    
    //MARK: Methods
    func setAPIData(apiKey: String?, secretKey: String?) {
        apiStorage.setAPIData(apiKey: apiKey, secretKey: secretKey)
    }
    
    func getAPIKey() -> String? {
        apiStorage.getAPIKey()
    }
    
    func getSecretKey() -> String? {
        apiStorage.getSecretKey()
    }
    
    func setFiatFilter(for newFiatFilter: C2CHistoryResponse.C2COrderFiat) {
        UserDefaults.standard.setValue(newFiatFilter.rawValue, forKey: userDefaultsFiatFilterKey)
        fiatFilter = newFiatFilter
    }
    
    func getFiatFilter() -> C2CHistoryResponse.C2COrderFiat {
        return fiatFilter
    }
    
    func setCustomFiatFilter(for newCustomFiat: String) {
        UserDefaults.standard.setValue(newCustomFiat, forKey: userDefaultsCustomFiatFilterKey)
        customFiatFilter = newCustomFiat
    }
    
    func getCustomFiatFilter() -> String {
        return customFiatFilter
    }
    
    func addAPIAccount(name: String, apiKey: String, secretKey: String, exchange: ExchangeConnection.Exchange, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.addAPIAccount(name: name, apiKey: apiKey, secretKey: secretKey, exchange: exchange, completionHandler: completionHandler)
    }
    
    func addAPIAccount(_ newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.addAPIAccount(newAccount, completionHandler: completionHandler)
    }
    
    func updateAccount(_ accountToUpdate: APIAccount, to newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.updateAccount(accountToUpdate, to: newAccount, completionHandler: completionHandler)
    }
    
    func deleteAccount(_ accountToDelete: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.deleteAccount(accountToDelete, completionHandler: completionHandler)
    }
    
    func deleteAccount(at index: Int, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.deleteAccount(at: index, completionHandler: completionHandler)
    }
    
    func moveAccounts(fromOffsets: IndexSet, toOffset: Int, completionHandler: (([APIAccount]?) -> Void)? = nil) {
        apiStorage.moveAccounts(fromOffsets: fromOffsets, toOffset: toOffset, completionHandler: completionHandler)
    }
    
    func getAccounts() -> [APIAccount] {
        apiStorage.getAccounts()
    }
}

//MARK: Mock object
final class DataStorageMock: DataStorageProtocol {
    private let apiStorage: APIStorageProtocol
    private var fiatFilter: C2CHistoryResponse.C2COrderFiat
    private var customFiatFilter: String
    
    init(apiStorage: APIStorageProtocol) {
        self.apiStorage = apiStorage
        fiatFilter = .allFiat
        customFiatFilter = ""
    }
    
    convenience init() {
        self.init(apiStorage: APIStorageMock())
    }
    
    func setAPIData(apiKey: String?, secretKey: String?) {
        apiStorage.setAPIData(apiKey: apiKey, secretKey: secretKey)
    }
    
    func getAPIKey() -> String? {
        apiStorage.getAPIKey()
    }
    
    func getSecretKey() -> String? {
        apiStorage.getSecretKey()
    }
    
    func setFiatFilter(for newFiatFilter: C2CHistoryResponse.C2COrderFiat) {
        fiatFilter = newFiatFilter
    }
    
    func getFiatFilter() -> C2CHistoryResponse.C2COrderFiat {
        return fiatFilter
    }
    
    func setCustomFiatFilter(for newCustomFiat: String) {
        customFiatFilter = newCustomFiat
    }
    
    func getCustomFiatFilter() -> String {
        return customFiatFilter
    }
    
    func addAPIAccount(name: String, apiKey: String, secretKey: String, exchange: ExchangeConnection.Exchange, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.addAPIAccount(name: name, apiKey: apiKey, secretKey: secretKey, exchange: exchange, completionHandler: completionHandler)
    }
    
    func addAPIAccount(_ newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.addAPIAccount(newAccount, completionHandler: completionHandler)
    }
    
    func updateAccount(_ accountToUpdate: APIAccount, to newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.updateAccount(accountToUpdate, to: newAccount, completionHandler: completionHandler)
    }
    
    func deleteAccount(_ accountToDelete: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.deleteAccount(accountToDelete, completionHandler: completionHandler)
    }
    
    func deleteAccount(at index: Int, completionHandler: ((APIAccount?) -> Void)?) {
        apiStorage.deleteAccount(at: index, completionHandler: completionHandler)
    }
    
    func moveAccounts(fromOffsets: IndexSet, toOffset: Int, completionHandler: (([APIAccount]?) -> Void)? = nil) {
        apiStorage.moveAccounts(fromOffsets: fromOffsets, toOffset: toOffset, completionHandler: completionHandler)
    }
    
    func getAccounts() -> [APIAccount] {
        apiStorage.getAccounts()
    }
}
