//
//  AppAppearanceManager.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 28.09.2023.
//

import Foundation
import SwiftUI

/// Object to provide different ways for App appearance, like color, Icon and etc
struct AppAppearanceVariables {
    static let defaultColor = Color("binanceColor")
    static let blueColor = Color.blue
    static let redColor = Color.red
    static let blackAndWhiteColor = Color.primary
    
    static let availableDefaultColors = [Self.defaultColor, Self.blueColor, Self.redColor, Self.blackAndWhiteColor]
}
