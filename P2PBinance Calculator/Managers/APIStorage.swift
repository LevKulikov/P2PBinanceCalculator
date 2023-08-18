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
    )
    
    /// Adds new API Account and saves it
    /// - Parameters:
    ///   - newAccount: New API Account structure
    ///   - completionHandler: Completion handler, provides new account if there is success, and nil if it is not
    func addAPIAccount(_ newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?)
    
    /// Updates existing account to new one
    /// - Parameters:
    ///   - accountToUpdate: previous account
    ///   - newAccount: new account to replace previous
    ///   - completionHandler: Completion handler, provides new account if there is success, and nil if it is not
    func updateAccount(_ accountToUpdate: APIAccount, to newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?)
    
    /// Deletes existing account
    /// - Parameters:
    ///   - accountToDelete: Account that should be deleted
    ///   - completionHandler: Completion handler, provides deleted account if there is success, and nil if it is not
    func deleteAccount(_ accountToDelete: APIAccount, completionHandler: ((APIAccount?) -> Void)?)
    
    /// Deletes existing account at specific index
    /// - Parameters:
    ///   - index: index of account to delete
    ///   - completionHandler: Completion handler, provides deleted account if there is success, and nil if it is not
    func deleteAccount(at index: Int, completionHandler: ((APIAccount?) -> Void)?)
    
    /// Provides saved accounts
    /// - Returns: all saved accounts
    func getAccounts() -> [APIAccount]
}

/// Object that stores user API data
class APIStorage: APIStorageProtocol {
    //MARK: Properties
    private var apiKey: String?
    private var secretKey: String?
    private var accounts: [APIAccount] = []
    /// Key for UserDefaults to get API Key
    private let userDefaultsApiKey = "userDefaultsApiKey"
    /// Key for UserDefaults to get Secret Key
    private let userDefaultsSecretKey = "userDefaultsSecretKey"
    /// Key for UserDefaults to get API Accounts array
    private let userDefaultsAccounts = "userDefaultsAccounts"
    
    //MARK: Initializer
    init() {
        apiKey = UserDefaults.standard.string(forKey: userDefaultsApiKey)
        secretKey = UserDefaults.standard.string(forKey: userDefaultsSecretKey)
        if let data = UserDefaults.standard.value(forKey: userDefaultsAccounts) as? Data,
           let savedAccounts = try? PropertyListDecoder().decode(Array<APIAccount>.self, from: data) {
            accounts = savedAccounts
        }
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
    
    func addAPIAccount(
        name: String,
        apiKey: String,
        secretKey: String,
        completionHandler: ((APIAccount?) -> Void)? = nil
    ) {
        let newAccount = APIAccount(name: name, apiKey: apiKey, secretKey: secretKey)
        addAPIAccount(newAccount, completionHandler: completionHandler)
    }
    
    func addAPIAccount(_ newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)? = nil) {
        accounts.append(newAccount)
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(accounts), forKey: userDefaultsAccounts)
            completionHandler?(newAccount)
        } catch {
            completionHandler?(nil)
        }
    }
    
    func updateAccount(_ accountToUpdate: APIAccount, to newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)? = nil) {
        guard let index = accounts.firstIndex(of: accountToUpdate) else {
            completionHandler?(nil)
            return
        }
        
        accounts.remove(at: index)
        
        accounts.insert(newAccount, at: index)
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(accounts), forKey: userDefaultsAccounts)
            completionHandler?(newAccount)
        } catch {
            completionHandler?(nil)
        }
    }
    
    func deleteAccount(at index: Int, completionHandler: ((APIAccount?) -> Void)?) {
        let deletedAccount = accounts.remove(at: index)
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(accounts), forKey: userDefaultsAccounts)
            completionHandler?(deletedAccount)
        } catch {
            completionHandler?(nil)
        }
    }
    
    func deleteAccount(_ accountToDelete: APIAccount, completionHandler: ((APIAccount?) -> Void)? = nil) {
        guard let index = accounts.firstIndex(of: accountToDelete) else {
            completionHandler?(nil)
            return
        }
        
        deleteAccount(at: index, completionHandler: completionHandler)
    }
    
    func getAccounts() -> [APIAccount] {
        return accounts
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
    private var accounts: [APIAccount] = [
        APIAccount(name: "Fizz", apiKey: "nkjwherkjkj2934234hjkjr", secretKey: "fhdsakh234kjh2jk3h4h2r32rh"),
        APIAccount(name: "Buzz", apiKey: "52983uhrkj2h3j4h234", secretKey: "fhwk234hjk23h4hr92hfh")
    ]
    
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
    
    func addAPIAccount(name: String, apiKey: String, secretKey: String, completionHandler: ((APIAccount?) -> Void)?) {
        let newAccount = APIAccount(name: name, apiKey: apiKey, secretKey: secretKey)
        addAPIAccount(newAccount, completionHandler: completionHandler)
    }
    
    func addAPIAccount(_ newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        accounts.append(newAccount)
        completionHandler?(newAccount)
    }
    
    func updateAccount(_ accountToUpdate: APIAccount, to newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        guard let index = accounts.firstIndex(of: accountToUpdate) else {
            completionHandler?(nil)
            return
        }
        
        accounts.remove(at: index)
        
        accounts.insert(newAccount, at: index)
        completionHandler?(newAccount)
    }
    
    func deleteAccount(at index: Int, completionHandler: ((APIAccount?) -> Void)?) {
        let deletedAccount = accounts.remove(at: index)
        completionHandler?(deletedAccount)
    }
    
    func deleteAccount(_ accountToDelete: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        guard let index = accounts.firstIndex(of: accountToDelete) else {
            completionHandler?(nil)
            return
        }
        
        deleteAccount(at: index, completionHandler: completionHandler)
    }
    
    func getAccounts() -> [APIAccount] {
        return accounts
    }
}
