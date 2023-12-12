//
//  BinanceConnection.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import CryptoKit
import Foundation

class ExchangeConnection {
    private struct PayloadBuilder {
        
        enum SecurityType {
            
            case none
            case trade(secret: String), margin(secret: String), userData(secret: String)
            case userStream, marketData
            
            var secret: String? {
                switch self {
                case .trade(secret: let secret), .margin(secret: let secret), .userData(secret: let secret):
                    return secret
                default:
                    return nil
                }
            }
        }
        
        let payload: String
        let timestamp: Bool
        let security: SecurityType
        
        func build() -> String {
            var built = payload
            
            if case .none = security {
                return payload
            }
            
            if timestamp {
                built = "\(built)&timestamp=\(Int64(Date().timeIntervalSince1970 * 1000))"
            }
            
            guard let secret = security.secret else { return built }
            
            let key = SymmetricKey(data: secret.data(using: .utf8)!)
            
            let signature = HMAC<SHA256>.authenticationCode(for: built.data(using: .utf8)!, using: key)
            
            return "\(built)&signature=\(Data(signature).map { String(format: "%02hhx", $0) }.joined())"
        }
    }
    
    enum Exchange: String, Codable, CaseIterable {
        case binance = "Binance"
        case commex = "CommEX"
    }
    
    enum BinanceAPIPath: String {
        case c2cOrderHistory = "/sapi/v1/c2c/orderMatch/listUserOrderHistory"
    }
    
    enum CommexAPIPath: String {
        case c2cOrderHistory = "/api/v1/c2c/order-match/list-order-history"
    }
    
    enum ExchangeError: String, Error {
        case invalidResponse = "Got invalid response"
        case connectionError = "Connection issues"
        case restrictionOrServerError = "Restriction or Server error"
        case gotNoData = "Got no data from response"
        case parseError = "Unable to parse data"
        case apiError = "Incorrect API Key data"
    }
    
    typealias AccountProfits = BinanceResponse.EarningsListResponse.Data.AccountProfits
    typealias SymbolPriceTicker = BinanceResponse.SymbolPriceTicker
    typealias Worker = BinanceResponse.MinerListResponse.Data.Worker
    
    static private let BinanceEndpoint = "https://api.binance.com"
    static private let CommExEndpoit = "https://api.commex.com"
    
    let apiKey: String
    let secretKey: String
    let exchange: Exchange
    
    init(apiKey: String, secretKey: String, exchange: Exchange) {
        self.apiKey = apiKey
        self.secretKey = secretKey
        self.exchange = exchange
    }
    
    private func performCall<T: Decodable>(withPath path: String, queryString: String, timestamp: Bool, securityType: PayloadBuilder.SecurityType, completionHandler: @escaping (Result<T, ExchangeError>) -> ()) {
        let payload = PayloadBuilder(payload: queryString, timestamp: timestamp, security: securityType).build()
        
        let endpoint: String
        switch exchange {
        case .binance:
            endpoint = ExchangeConnection.BinanceEndpoint
        case .commex:
            endpoint = ExchangeConnection.CommExEndpoit
        }
        
        let url = URL(string: "\(endpoint)\(path)?\(payload)")!
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-MBX-APIKEY")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil, let response = response as? HTTPURLResponse else {
                if let _ = error {
                    completionHandler(.failure(.connectionError))
                } else {
                    completionHandler(.failure(.invalidResponse))
                }
                return
            }
            
            if response.statusCode == 403 || response.statusCode == 500 {
                completionHandler(.failure(.restrictionOrServerError))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.gotNoData))
                return
            }
            
            do {
                let parsedResponse = try JSONDecoder().decode(T.self, from: data)
                completionHandler(.success(parsedResponse))
            } catch {
                print(error)
                print("\nDATA IS GOT:")
                let parsed = String(data: data, encoding: .utf8)
                print(parsed ?? "No value from data")
                completionHandler(.failure(.apiError))
            }
        }
        
        task.resume()
    }
    
    func getSymbolPriceTicker(symbol: String, completionHandler: @escaping (Result<SymbolPriceTicker, ExchangeError>) -> ()) {
        performCall(withPath: "/api/v3/ticker/price", queryString: "symbol=\(symbol)", timestamp: false, securityType: .marketData) { (result: Result<SymbolPriceTicker, ExchangeError>) in
            switch result {
            case .success(let response):
                completionHandler(.success(response))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func getBinanceC2COrderHistory(
        type: C2CHistoryResponse.C2COrderType,
        startTimestamp: Date? = nil,
        endTimestamp: Date? = nil,
        page: Int? = nil,
        rows: Int? = nil,
        completionHandler: @escaping(Result<C2CHistoryResponse, ExchangeError>) -> Void
    ) {
        var queryString = "tradeType=\(type.rawValue)"
        queryString += startTimestamp != nil ? "&startTimestamp=\(Int(startTimestamp!.timeIntervalSince1970 * 1000))" : ""
        queryString += endTimestamp != nil ? "&endTimestamp=\(Int(endTimestamp!.timeIntervalSince1970 * 1000))" : ""
        queryString += page != nil ? "&page=\(page!)" : ""
        queryString += rows != nil ? "&rows=\(rows!)" : ""
        
        performCall(
            withPath: BinanceAPIPath.c2cOrderHistory.rawValue,
            queryString: queryString,
            timestamp: true,
            securityType: .userData(secret: secretKey)
        ) { result in
            completionHandler(result)
        }
    }
    
    func getCommexC2COrderHistory(
        type: C2CHistoryResponse.C2COrderType,
        startTimestamp: Date? = nil,
        endTimestamp: Date? = nil,
        limit: Int = 200,
        completionHandler: @escaping(Result<CommexC2CHistoryResponse, ExchangeError>) -> Void
    ) {
        var queryString = "tradeType=\(type.rawValue)"
        queryString += startTimestamp != nil ? "&startTime=\(Int(startTimestamp!.timeIntervalSince1970 * 1000))" : ""
        queryString += endTimestamp != nil ? "&endTime=\(Int(endTimestamp!.timeIntervalSince1970 * 1000))" : ""
        queryString += "&offset=0"
        queryString += "&limit=\(limit)"
        
        performCall(
            withPath: CommexAPIPath.c2cOrderHistory.rawValue,
            queryString: queryString,
            timestamp: true,
            securityType: .userData(secret: secretKey)
        ) { result in
            completionHandler(result)
        }
    }
    
    
//   Commex C2CHistory Response query
//    tradeType    query    string    false    Possible options: "BUY", "SELL"
//    startTime    query    long    false    Default: 90 days from current timestamp
//    endTime    query    long    false    Default: present timestamp
//    offset    query    integer    true    Default:0
//    limit    query    integer    true    Default 100; max 200.
//    recvWindow    query    long    false    The value cannot be greater than 60000
//    timestamp    query    long    true    none
}
