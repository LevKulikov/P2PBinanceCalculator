//
//  GeneralViewModel.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import Foundation
import Combine

/// Object to get API calls
class GeneralViewModel: ObservableObject, DataStorageProtocol {
    //MARK: Properties
    @Published var selectedAccount: APIAccount? {
        didSet {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(selectedAccount), forKey: userDefaultsSelectedAccount)
        }
    }
    private let dataStorage: DataStorageProtocol
    private let userDefaultsSelectedAccount = "userDefaultsSelectedAccount"
    
    //MARK: Initializer
    init(dataStorage: DataStorageProtocol) {
        self.dataStorage = dataStorage
        
        if let data = UserDefaults.standard.value(forKey: userDefaultsSelectedAccount) as? Data,
           let account = try? PropertyListDecoder().decode(APIAccount.self, from: data) {
            selectedAccount = account
        }
    }
    
    //MARK: Methods
    /// Calls Binance API to get C2C History
    /// - Parameters:
    ///   - type: order type, buy or sell
    ///   - startTimestamp: start time for first order
    ///   - endTimestamp: end time for last order
    ///   - page: pages to get
    ///   - rows: rows to get
    ///   - completionHandler: closure to get result
    func getC2CHistory(
        type: C2CHistoryResponse.C2COrderType,
        startTimestamp: Date? = nil,
        endTimestamp: Date? = nil,
        page: Int? = nil,
        rows: Int? = nil,
        completionHandler: @escaping (Result<[C2CHistoryResponse.C2COrderTransformed], BinanceConnection.BinanceError>) -> Void
    ) { 
        guard let selectedAccount else {
            completionHandler(.failure(.apiError))
            return
        }
        
        let connection = BinanceConnection(apiKey: selectedAccount.apiKey, secretKey: selectedAccount.secretKey)
        connection.getC2COrderHistory(
            type: type,
            startTimestamp: startTimestamp != nil ? startTimestamp!.startOfDay : nil,
            endTimestamp: (endTimestamp ?? Date.now).startOfDay == Date.now.startOfDay ? Date.now : Calendar.current.date(byAdding: .second, value: -1, to: endTimestamp!.dayAfter.startOfDay),
            page: page,
            rows: rows
        ) { result in
            switch result {
            case .success(let success):
                completionHandler(
                    .success(
                        success.data.map { C2CHistoryResponse.C2COrderTransformed(order: $0) }
                    )
                )
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
    func setAPIData(apiKey: String?, secretKey: String?) {
        dataStorage.setAPIData(apiKey: apiKey, secretKey: secretKey)
    }
    
    func getAPIKey() -> String? {
        dataStorage.getAPIKey()
    }
    
    func getSecretKey() -> String? {
        dataStorage.getSecretKey()
    }
    
    func setFiatFilter(for newFiatFilter: C2CHistoryResponse.C2COrderFiat) {
        dataStorage.setFiatFilter(for: newFiatFilter)
    }
    
    func getFiatFilter() -> C2CHistoryResponse.C2COrderFiat {
        dataStorage.getFiatFilter()
    }
    
    func addAPIAccount(name: String, apiKey: String, secretKey: String, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.addAPIAccount(name: name, apiKey: apiKey, secretKey: secretKey, completionHandler: completionHandler)
    }
    
    func addAPIAccount(_ newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.addAPIAccount(newAccount, completionHandler: completionHandler)
    }
    
    func updateAccount(_ accountToUpdate: APIAccount, to newAccount: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.updateAccount(accountToUpdate, to: newAccount, completionHandler: completionHandler)
    }
    
    func deleteAccount(_ accountToDelete: APIAccount, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.deleteAccount(accountToDelete, completionHandler: completionHandler)
    }
    
    func deleteAccount(at index: Int, completionHandler: ((APIAccount?) -> Void)?) {
        dataStorage.deleteAccount(at: index, completionHandler: completionHandler)
    }
    
    func getAccounts() -> [APIAccount] {
        dataStorage.getAccounts()
    }
}

class GeneralViewModelMock: GeneralViewModel {
    override func getC2CHistory(type: C2CHistoryResponse.C2COrderType, startTimestamp: Date? = nil, endTimestamp: Date? = nil, page: Int? = nil, rows: Int? = nil, completionHandler: @escaping (Result<[C2CHistoryResponse.C2COrderTransformed], BinanceConnection.BinanceError>) -> Void) {
        let orders = [
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "02394273598234599238523",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "USDT",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .inAppeal,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "3241234214234234645643",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "USDT",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .completed,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "43987209347850823403",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "USDT",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .completed,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
                
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "8327491840123984",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "BTC",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .cancelled,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "43987209347150823403",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "BTC",
                fiat: "UAH",
                fiatSymbol: "U₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .completed,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "43987209347150823413",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "USDT",
                fiat: "AZT",
                fiatSymbol: "G₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .cancelledBySystem,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "43987209347950823403",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "LTC",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .completed,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "33987209347950823403",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "BUSD",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .completed,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "23987209347950823403",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "BNB",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .completed,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "53987209347950823403",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "ETH",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .completed,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
            C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "33987209347950823403",
                advNo: "84792837409127439234",
                tradeType: type,
                asset: "RUB",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .completed,
                createTime: 1619361369000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            ),
        ]
        
        completionHandler(.success(orders))
    }
}
