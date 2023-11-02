//
//  BinanceNavigationStack.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 06.08.2023.
//

import Foundation
import SwiftUI

extension NavigationStack {
    init(root: () -> Root, titleColor: Color) {
        self.init(root: root)
    }
}
