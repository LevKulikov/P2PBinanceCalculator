//
//  BinanceResponse.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import Foundation

enum BinanceResponse {
    
    enum APIError: Error {
        case decodingError
    }
    
     struct EarningsListResponse: Codable {
        
        struct Data: Codable {
            
            struct AccountProfits: Codable {
                
                enum ProfitType: Int, Codable {
                    case miningWallet = 0
                    case miningAddress = 5
                    case poolSavings = 7
                    case transfered = 8
                    case incomeTransfer = 31
                    case hashrateResaleMiningWallet = 32
                    case hashrateResalePoolSavings = 33
                }
                
                enum Status: Int, Codable {
                    case unpaid = 0
                    case paying = 1
                    case paid = 2
                }
                
                let time: Int
                let type: ProfitType
                let hashTransfer: Double?
                let transferAmount: Double?
                let dayHashRate: Double
                let profitAmount: Double
                let coinName: String
                let status: Status
            }
            
            let accountProfits: [AccountProfits]
        }
        
        let code: Int
        let msg: String
        let data: Data
    }
    
    struct MinerListResponse: Codable {
        
        struct Data: Codable {
            
            struct Worker: Codable {
                
                enum Status: Int, Codable {
                    case valid = 1
                    case invalid = 2
                    case noLongerValid = 3
                }
                
                let workerId: String
                let workerName: String
                let status: Status
                let hashRate: Double
                let dayHashRate: Double
                let rejectRate: Double
                let lastShareTime: Double
            }
            
            let workerDatas: [Worker]
        }
        
        let code: Int
        let msg: String
        let data: Data
    }
    
    struct SymbolPriceTicker: Codable {
        
        let symbol: String
        let price: Double
        
        enum CodingKeys: String, CodingKey {
            case symbol
            case price
        }
        
        init?(json: [String: Any]) {
            guard let symbol = json["symbol"] as? String else { return nil }
            guard let priceAsString = json["price"] as? String else { return nil }
            guard let price = Double(priceAsString) else { return nil }
            
            self.symbol = symbol
            self.price = price
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let priceAsString = try values.decode(String.self, forKey: .price)
            
            guard let price = Double(priceAsString) else {
                throw APIError.decodingError
            }
            
            self.symbol = try values.decode(String.self, forKey: .symbol)
            self.price = price
        }
    }
}
