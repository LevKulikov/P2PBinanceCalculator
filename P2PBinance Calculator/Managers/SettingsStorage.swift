//
//  SettingsStorage.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 27.09.2023.
//

import Foundation
import SwiftUI

protocol SettingsStorageProtocol: AnyObject {
    /// Provides previously saved if role filter should be shown
    var savedRoleFilterShow: Bool { get }
    
    /// Provides previously saved if date range filter should be shown
    var savedDateRangeFilterShow: Bool { get }
    
    /// Provides previously saved if amount filter should be shown
    var savedAmountFilterShow: Bool { get }
    
    /// Saves if role filter should be shown or not
    /// - Parameter show:role filter should be shown or not
    func setRoleFilter(show: Bool)
    
    /// Saves if date range filter should be shown or not
    /// - Parameter show: date range filter should be shown or not
    func setDateRangeFilter(show: Bool)
    
    /// Saves if amount filter should be shown or not
    /// - Parameter show: amount filter should be shown or not
    func setAmountFilter(show: Bool)
    
    /// Saves app color to display
    /// - Parameter color: color to save
    func setAppColor(_ color: Color)
}

class SettingsStorage: SettingsStorageProtocol {
    //MARK: - Properties
    /// Static property to provide which color should be for entire app
    static var pickedAppColor: Color {
        return Self.appColor
    }
    /// Private static property to change color
    private static var appColor: Color = AppAppearanceVariables.defaultColor
    
    private let roleFilterShowUserDefaultsKey = "roleFilterShowUserDefaultsKey"
    private let dateRangeFilterShowUserDefaultsKey = "dateRangeFilterShowUserDefaultsKey"
    private let amountFilterShowUserDefaultsKey = "amountFilterShowUserDefaultsKey"
    private let appColorUserDefaultsKey = "appColorUserDefaultsKey"
    
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
        
        if let savedColorData = UserDefaults.standard.data(forKey: appColorUserDefaultsKey), let uiColor = UIColor.color(data: savedColorData) {
            Self.appColor = Color(uiColor: uiColor)
        } else {
            Self.appColor = AppAppearanceVariables.defaultColor
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
    
    func setAppColor(_ color: Color) {
        guard let colorData = UIColor(color).encode() else {
            print("Error: SettingsStorage, setAppColor(_ color:), Unable to encode color to save")
            return
        }
        
        UserDefaults.standard.setValue(colorData, forKey: appColorUserDefaultsKey)
        Self.appColor = color
    }
}

//MARK: - Mock object for SettingsStorage
class SettingsStorageMock: SettingsStorageProtocol {
    private var roleFilterShow: Bool
    private var dateRangeFilterShow: Bool
    private var amountFilterShow: Bool
    static var appColor = AppAppearanceVariables.defaultColor
    
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
    
    func setAppColor(_ color: Color) {
        Self.appColor = color
    }
}
