//
//  DataStorage.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 11.08.2023.
//

import Foundation

/// Protocol for object that stores app data
protocol DataStorageProtocol: AnyObject, APIStorageProtocol {
    /// Property that shows there exists saved API data
    var apiDataSet: Bool { get }
    
    /// Saves new fiat filter
    /// - Parameter newFiatFilter: New fiat filter set by user
    func setFiatFilter(for newFiatFilter: C2CHistoryResponse.C2COrderFiat)
    
    /// Provides previously saved fiat filter
    /// - Returns: Saved fiat filter
    func getFiatFilter() -> C2CHistoryResponse.C2COrderFiat
}

/// Object that stores app data
class DataStorage: DataStorageProtocol {
    //MARK: Properties
    var apiDataSet: Bool {
        return apiStorage.getAPIKey() != nil && apiStorage.getSecretKey() != nil
    }
    private let apiStorage: APIStorageProtocol
    /// Saved fiat filter set by user previously
    private var fiatFilter: C2CHistoryResponse.C2COrderFiat
    private let userDefaultsFiatFilterKey = "userDefaultsFiatFilterKey"
    
    //MARK: Initializer
    init(apiStorage: APIStorageProtocol) {
        self.apiStorage = apiStorage
        let fiatRawValue = UserDefaults.standard.string(forKey: userDefaultsFiatFilterKey) ?? C2CHistoryResponse.C2COrderFiat.allFiat.rawValue
        fiatFilter = C2CHistoryResponse.C2COrderFiat(rawValue: fiatRawValue) ?? C2CHistoryResponse.C2COrderFiat.allFiat
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
}

//MARK: Mock object
class DataStorageMock: DataStorageProtocol {
    var apiDataSet: Bool {
        return true
    }
    private let apiStorage: APIStorageProtocol
    private var fiatFilter: C2CHistoryResponse.C2COrderFiat
    
    init(apiStorage: APIStorageProtocol) {
        self.apiStorage = apiStorage
        fiatFilter = .allFiat
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
}
