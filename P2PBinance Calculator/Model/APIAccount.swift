//
//  APIAccount.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 18.08.2023.
//

import Foundation

struct APIAccount: Identifiable, Equatable, Hashable {
    let id = UUID()
    
    var name: String
    var apiKey: String
    var secretKey: String
}
