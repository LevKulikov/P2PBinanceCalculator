//
//  DataStorage.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 11.08.2023.
//

import Foundation

/// Protocol for object that stores user API data
protocol APIStorageProtocol: AnyObject {
    /// Saves API key data
    /// - Parameters:
    ///   - apiKey: user Binance API Key, if nil property does not change
    ///   - secretKey: user Binance Secret Key, if nil property does not change
    func setAPIData(apiKey: String?, secretKey: String?)
    
    /// Provides user API Key
    /// - Returns: Previosly saved API Key, nil if there is no any
    func getAPIKey() -> String?
    
    /// Provides user Secret Key
    /// - Returns: Previosly saved Secret Key, nil if there is no any
    func getSecretKey() -> String?
}

/// Object that stores user API data
class APIStorage: APIStorageProtocol {
    //MARK: Properties
    private var apiKey: String?
    private var secretKey: String?
    /// Key for UserDefaults to get API Key
    private let userDefaultsApiKey = "userDefaultsApiKey"
    /// Key for UserDefaults to get Secret Key
    private let userDefaultsSecretKey = "userDefaultsSecretKey"
//    private var accounts
    
    //MARK: Initializer
    init() {
        apiKey = UserDefaults.standard.string(forKey: userDefaultsApiKey)
        secretKey = UserDefaults.standard.string(forKey: userDefaultsSecretKey)
    }
    
    //MARK: Methods
    func setAPIData(apiKey: String?, secretKey: String?) {
        if let apiKey, !apiKey.isEmpty {
            UserDefaults.standard.setValue(apiKey, forKey: userDefaultsApiKey)
            self.apiKey = apiKey
        }
        
        if let secretKey, !secretKey.isEmpty {
            UserDefaults.standard.setValue(secretKey, forKey: userDefaultsSecretKey)
            self.secretKey = secretKey
        }
    }
    
    func getAPIKey() -> String? {
        return apiKey
    }
    
    func getSecretKey() -> String? {
        return secretKey
    }
}

//MARK: Mock object
class APIStorageMock: APIStorageProtocol {
    private var apiKey: String? = "fasfdskhfjfkjsjhrk92834234jkhkjfhkdaf"
    private var secretKey: String? = "fasfdskhfjfkjsjhrk92834234jkhkjfhkdaf"
    
    func setAPIData(apiKey: String?, secretKey: String?) {
        if let apiKey, !apiKey.isEmpty {
            self.apiKey = apiKey
        }
        
        if let secretKey, !secretKey.isEmpty {
            self.secretKey = secretKey
        }
    }
    
    func getAPIKey() -> String? {
        return apiKey
    }
    
    func getSecretKey() -> String? {
        return secretKey
    }
}
