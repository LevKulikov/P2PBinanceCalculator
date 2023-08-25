//
//  C2CHistoryResponse.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import Foundation

/// Model for total response of P2P (C2C) orders history
struct C2CHistoryResponse: Codable {
    
    enum C2COrderAsset: String, CaseIterable {
        case allAssets = "All assets"
        case usdt = "USDT"
        case btc = "BTC"
        case busd = "BUSD"
        case bnb = "BNB"
        case eth = "ETH"
        case fdusd = "FDUSD"
        case rub = "RUB"
        case usd = "USD"
        case eur = "EUR"
        case other = "Other"
        
        static let mentionedAssets = Array(Self.allCases.drop { $0 == .other })
    }
    
    enum C2COrderFiat: String, CaseIterable {
        case allFiat = "All fiat"
        case rub = "RUB"
        case uah = "UAH"
        case usd = "USD"
        case eur = "EUR"
        case other = "Other"
        
        static let mentionedFiat = Array(Self.allCases.drop { $0 == .other })
    }
    
    enum C2COrderType: String, Codable, CaseIterable {
        case buy = "BUY"
        case sell = "SELL"
        case bothTypes = "Both types"
    }

    enum C2COrderStatus: String, Codable, CaseIterable {
        case all = "ALL"  // Mark for FilterView, cannot be matched from Binance JSON
        case completed = "COMPLETED"
        case pending = "PENDING"
        case trading = "TRADING"
        case buyerPayed = "BUYER_PAYED"
        case distributing = "DISTRIBUTING"
        case inAppeal = "IN_APPEAL"
        case cancelled = "CANCELLED"
        case cancelledBySystem = "CANCELLED_BY_SYSTEM"
        
        static let warningStatus: [C2COrderStatus] = [pending, trading, buyerPayed, distributing, inAppeal]
        static let basicStatus: [C2COrderStatus] = [completed, cancelled, cancelledBySystem]
    }
    
    /// Model for one P2P (C2C) order data from JSON
    struct C2COrder: Codable, Identifiable, Equatable {
        let id = UUID()
        
        let orderNumber: String
        let advNo: String
        let tradeType: C2COrderType
        let asset: String
        let fiat: String
        let fiatSymbol: String
        let amount: String
        let totalPrice: String
        let unitPrice: String
        let orderStatus: C2COrderStatus
        let createTime: Int
        let commission: String
        let counterPartNickName: String
        let advertisementRole: String
    }
    
    /// Model for C2COrder that can contain other properties
    struct C2COrderTransformed: Identifiable, Equatable, Hashable {
        let id = UUID()
        var activeForCount = true
        
        let orderNumber: String
        let advNo: String
        let tradeType: C2COrderType
        let asset: String
        let fiat: String
        let fiatSymbol: String
        let amount: Float
        let totalPrice: Float
        let unitPrice: Float
        let orderStatus: C2COrderStatus
        let createTime: Date
        let commission: Float
        let counterPartNickName: String
        let advertisementRole: String
        
        init(orderNumber: String, advNo: String, tradeType: C2COrderType, asset: String, fiat: String, fiatSymbol: String, amount: String, totalPrice: String, unitPrice: String, orderStatus: C2COrderStatus, createTime: Int, commission: String, counterPartNickName: String, advertisementRole: String) {
            self.orderNumber = orderNumber
            self.advNo = advNo
            self.tradeType = tradeType
            self.asset = asset
            self.fiat = fiat
            self.fiatSymbol = fiatSymbol
            self.amount = Float(amount) ?? 0
            self.totalPrice = Float(totalPrice) ?? 0
            self.unitPrice = Float(unitPrice) ?? 0
            self.orderStatus = orderStatus
            self.createTime = Date(timeIntervalSince1970: TimeInterval(createTime / 1000))
            self.commission = Float(commission) ?? 0
            self.counterPartNickName = counterPartNickName
            self.advertisementRole = advertisementRole
        }
        
        init(order: C2COrder) {
            self.orderNumber = order.orderNumber
            self.advNo = order.advNo
            self.tradeType = order.tradeType
            self.asset = order.asset
            self.fiat = order.fiat
            self.fiatSymbol = order.fiatSymbol
            self.amount = Float(order.amount) ?? 0
            self.totalPrice = Float(order.totalPrice) ?? 0
            self.unitPrice = Float(order.unitPrice) ?? 0
            self.orderStatus = order.orderStatus
            self.createTime = Date(timeIntervalSince1970: TimeInterval(order.createTime / 1000))
            self.commission = Float(order.commission) ?? 0
            self.counterPartNickName = order.counterPartNickName
            self.advertisementRole = order.advertisementRole
        }
    }
    
    let code: String
    let message: String
    let data: [C2COrder]
    let total: Int
    let success: Bool
}
