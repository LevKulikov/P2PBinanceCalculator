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
        case other = "Other"
        case custom = "Custom:"
        
        static let mentionedAssets = Array(Self.allCases.filter { ![Self.allAssets, Self.other, Self.custom].contains($0) })
    }
    
    enum C2COrderFiat: String, CaseIterable {
        case allFiat = "All fiat"
        case rub = "RUB"
        case uah = "UAH"
        case usd = "USD"
        case eur = "EUR"
        case other = "Other"
        case custom = "Custom:"
        
        static let mentionedFiat = Array(Self.allCases.filter { ![Self.allFiat, Self.other, Self.custom].contains($0) })
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
        
        func humanName() -> String {
            switch self {
            case .all:
                return "All"
            case .completed:
                return "Completed"
            case .pending:
                return "Pending"
            case .trading:
                return "Trading"
            case .buyerPayed:
                return "Buyer payed"
            case .distributing:
                return "Distributing"
            case .inAppeal:
                return "In appeal"
            case .cancelled:
                return "Cancelled"
            case .cancelledBySystem:
                return "Cancelled by system"
            }
        }
    }
    
    enum C2COrderAdvertisementRole: String, Codable, CaseIterable {
        case bothRoles = "Both roles"
        case taker = "TAKER"
        case maker = "MAKER"
    }
    
    /// Model for one P2P (C2C) order data from JSON
    struct C2COrder: Codable {        
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
        let advertisementRole: C2COrderAdvertisementRole
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
        let advertisementRole: C2COrderAdvertisementRole
        
        init(orderNumber: String, advNo: String, tradeType: C2COrderType, asset: String, fiat: String, fiatSymbol: String, amount: String, totalPrice: String, unitPrice: String, orderStatus: C2COrderStatus, createTime: Int, commission: String, counterPartNickName: String, advertisementRole: C2COrderAdvertisementRole) {
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
        
        init(order: CommexC2CHistoryResponse.CommexC2COrder) {
            self.orderNumber = order.orderNumber
            self.advNo = order.adNo
            self.tradeType = order.tradeType
            self.asset = order.asset
            self.fiat = order.fiat
            self.fiatSymbol = order.fiatSymbol
            self.amount = Float(order.amount) ?? 0
            self.totalPrice = Float(order.totalPrice) ?? 0
            self.unitPrice = order.unitPrice
            self.orderStatus = order.orderStatus
            self.createTime = Date(timeIntervalSince1970: TimeInterval(order.createTime / 1000))
            self.commission = order.commission
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

/// Model of response for Commex, to make Orders History API call
struct CommexC2CHistoryResponse: Codable {
    struct CommexC2COrder: Codable {
        let orderNumber: String
        let adNo: String
        let tradeType: C2CHistoryResponse.C2COrderType
        let asset: String
        let fiat: String
        let fiatSymbol: String
        let amount: String
        let totalPrice: String
        let unitPrice: Float
        let orderStatus: C2CHistoryResponse.C2COrderStatus
        let createTime: Int
        let commission: Float
        let counterPartNickName: String
        let advertisementRole: C2CHistoryResponse.C2COrderAdvertisementRole
    }
    
    let total: Int
    let data: [CommexC2COrder]
}
