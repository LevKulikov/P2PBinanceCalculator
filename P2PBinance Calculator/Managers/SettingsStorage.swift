//
//  SettingsStorage.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 27.09.2023.
//

import Foundation

protocol SettingsStorageProtocol: AnyObject {
    /// Provides previously saved if role filter should be shown 
    var savedRoleFilterShow: Bool { get }
    
    /// Provides previously saved if date range filter should be shown
    var savedDateRangeFilterShow: Bool { get }
    
    /// Provides previously saved if amount filter should be shown
    var savedAmountFilterShow: Bool { get }
    
    /// Safes if role filter should be shown or not
    /// - Parameter show:role filter should be shown or not
    func setRoleFilter(show: Bool)
    
    /// Safes if date range filter should be shown or not
    /// - Parameter show: date range filter should be shown or not
    func setDateRangeFilter(show: Bool)
    
    /// Safes if amount filter should be shown or not
    /// - Parameter show: amount filter should be shown or not
    func setAmountFilter(show: Bool)
}

class SettingsStorage: SettingsStorageProtocol {
    //MARK: - Properties
    private let roleFilterShowUserDefaultsKey = "roleFilterShowUserDefaultsKey"
    private let dateRangeFilterShowUserDefaultsKey = "dateRangeFilterShowUserDefaultsKey"
    private let amountFilterShowUserDefaultsKey = "amountFilterShowUserDefaultsKey"
    
    private var roleFilterShow: Bool
    private var dateRangeFilterShow: Bool
    private var amountFilterShow: Bool
    
    var savedRoleFilterShow: Bool {
        roleFilterShow
    }
    var savedDateRangeFilterShow: Bool {
        dateRangeFilterShow
    }
    var savedAmountFilterShow: Bool {
        amountFilterShow
    }
    
    //MARK: - Initializer
    init() {
        if let roleShow = UserDefaults.standard.object(forKey: roleFilterShowUserDefaultsKey) as? Bool {
            roleFilterShow = roleShow
        } else {
            roleFilterShow = true
        }
        
        if let dateRangeShow = UserDefaults.standard.object(forKey: dateRangeFilterShowUserDefaultsKey) as? Bool {
            dateRangeFilterShow = dateRangeShow
        } else {
            dateRangeFilterShow = true
        }
        
        if let amountShow = UserDefaults.standard.object(forKey: amountFilterShowUserDefaultsKey) as? Bool {
            amountFilterShow = amountShow
        } else {
            amountFilterShow = true
        }
    }
    
    //MARK: - Methods
    func setRoleFilter(show: Bool) {
        UserDefaults.standard.setValue(show, forKey: roleFilterShowUserDefaultsKey)
        roleFilterShow = show
    }
    
    func setDateRangeFilter(show: Bool) {
        UserDefaults.standard.setValue(show, forKey: dateRangeFilterShowUserDefaultsKey)
        dateRangeFilterShow = show
    }
    
    func setAmountFilter(show: Bool) {
        UserDefaults.standard.setValue(show, forKey: amountFilterShowUserDefaultsKey)
        amountFilterShow = show
    }
}

//MARK: - Mock object for SettingsStorage
class SettingsStorageMock: SettingsStorageProtocol {
    private var roleFilterShow: Bool
    private var dateRangeFilterShow: Bool
    private var amountFilterShow: Bool
    
    var savedRoleFilterShow: Bool {
        roleFilterShow
    }
    var savedDateRangeFilterShow: Bool {
        dateRangeFilterShow
    }
    var savedAmountFilterShow: Bool {
        amountFilterShow
    }
    
    init() {
        roleFilterShow = true
        dateRangeFilterShow = true
        amountFilterShow = true
    }
    
    func setRoleFilter(show: Bool) {
        roleFilterShow = show
    }
    
    func setDateRangeFilter(show: Bool) {
        dateRangeFilterShow = show
    }
    
    func setAmountFilter(show: Bool) {
        amountFilterShow = show
    }
}
