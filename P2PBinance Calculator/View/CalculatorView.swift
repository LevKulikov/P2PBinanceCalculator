//
//  CalculatorView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 08.08.2023.
//

import SwiftUI

struct CalculatorView: View {
    // Init
    var currentOrderFiat: C2CHistoryResponse.C2COrderFiat
    var currentOrderTypeFilter: C2CHistoryResponse.C2COrderType
    var c2cOrders: [C2CHistoryResponse.C2COrderTransformed]
    var c2cOrdersSecondType: [C2CHistoryResponse.C2COrderTransformed]
    // To use in calculations
    private var c2cOrdersCompleted: [C2CHistoryResponse.C2COrderTransformed] {
        return c2cOrders.filter { $0.orderStatus == .completed }
    }
    private var c2cOrdersSecondTypeCompleted: [C2CHistoryResponse.C2COrderTransformed] {
        return c2cOrdersSecondType.filter { $0.orderStatus == .completed }
    }
    // Calculations
    private var firstOrdersValue: Float {
        c2cOrdersCompleted.compactMap { Float($0.totalPrice) }.reduce(0, +)
    }
    private var secondOrdersValue: Float {
        c2cOrdersSecondTypeCompleted.compactMap { Float($0.totalPrice) }.reduce(0, +)
    }
    private var firstOrdersCommissionFiat: Float {
        c2cOrdersCompleted.map {
            (Float($0.commission) ?? 0) * (Float($0.unitPrice) ?? 0)
        }.reduce(0, +)
    }
    private var secondOrdersCommissionFiat: Float {
        c2cOrdersSecondTypeCompleted.map {
            (Float($0.commission) ?? 0) * (Float($0.unitPrice) ?? 0)
        }.reduce(0, +)
    }
    /// Sell orders minus buy orders
    private var ordersProfit: Float {
        if currentOrderTypeFilter == .buy {
            return secondOrdersValue - firstOrdersValue
        } else {
            return firstOrdersValue - secondOrdersValue
        }
    }
    /// Sell orders devide for buy orders spread
    private var ordersSpread: Float {
        if currentOrderTypeFilter == .buy {
            return (secondOrdersValue/firstOrdersValue-1)*100
        } else {
            return (firstOrdersValue/secondOrdersValue-1)*100
        }
    }
    
    var body: some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            craateViewForCalculator()
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(1/8)))
                .presentationBackground(.clear)
        } else {
            craateViewForCalculator()
        }
    }
    
    @ViewBuilder
    private func craateViewForCalculator() -> some View {
        VStack(alignment: .leading) {
            Text("Calculator")
                .font(.largeTitle)
                .bold()
                .padding(.top)
                .padding(.bottom)
            
            HStack(spacing: 0) {
                Text("Orders value \(currentOrderFiat.rawValue): ")
                Text((firstOrdersValue + secondOrdersValue).currencyRU).underline(color: .gray)
                    .contextMenu {
                        Button {
                            copyAsPlainText("\(firstOrdersValue + secondOrdersValue)")
                        } label: {
                            Label("Copy total value", systemImage: "doc.on.doc")
                        }
                    } preview: {
                        VStack {
                            Text("Buy: \(currentOrderTypeFilter == .buy ? firstOrdersValue.currencyRU : secondOrdersValue.currencyRU)")
                            Text("Sell: \(currentOrderTypeFilter == .buy ? secondOrdersValue.currencyRU : firstOrdersValue.currencyRU)")
                        }
                        .font(.title2)
                        .padding()
                    }
            }
            .font(.title2)
            .padding(.bottom, 1)
            
            HStack(spacing: 0) {
                Text("Orders profit: ")
                Text(ordersProfit.currencyRU).underline(color: .gray)
                    .contextMenu {
                        Button {
                            copyAsPlainText("\(ordersProfit)")
                        } label: {
                            Label("Copy profit", systemImage: "doc.on.doc")
                        }
                    } preview: {
                        VStack {
                            Text("Buy: \(currentOrderTypeFilter == .buy ? firstOrdersValue.currencyRU : secondOrdersValue.currencyRU)")
                            Text("Sell: \(currentOrderTypeFilter == .buy ? secondOrdersValue.currencyRU : firstOrdersValue.currencyRU)")
                            Text("Commission: \((firstOrdersCommissionFiat + secondOrdersCommissionFiat).currencyRU)")
                        }
                        .font(.title2)
                        .padding()
                    }
            }
            .font(.title2)
            .padding(.bottom, 1)
            
            HStack(spacing: 0) {
                Text("Orders medium spread: ")
                Text("\(ordersSpread.currencyRU)%").underline(color: .gray)
                    .contextMenu {
                        Button {
                            copyAsPlainText("\(ordersSpread)")
                        } label: {
                            Label("Copy spread %", systemImage: "doc.on.doc")
                        }
                    } preview: {
                        VStack {
                            Text("Sell: \(currentOrderTypeFilter == .buy ? secondOrdersValue.currencyRU : firstOrdersValue.currencyRU)")
                                .font(.title2)
                            Text("/")
                                .font(.title)
                                .rotationEffect(.degrees(45))
                            Text("Buy: \(currentOrderTypeFilter == .buy ? firstOrdersValue.currencyRU : secondOrdersValue.currencyRU)")
                                .font(.title2)
                        }
                        .padding()
                    }
            }
            .font(.title2)
            .padding(.bottom)
            
            HStack(spacing: 0) {
                Text("Only completed orders are counted.\nOrdes value = buy + sell orders.\nProfit calculation takes into account commission costs.")
                +
                Text("\nErrors are possible if there were buy orders without subsequent sale and vice versa!").bold()
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
//            RoundedRectangle(cornerRadius: 15)
//                .fill(.orange)
//                .ignoresSafeArea()
//                .overlay {
//                    Text("Here will be additional information")
//                        .font(.largeTitle)
//                        .italic()
//                        .underline()
//                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(
            currentOrderFiat: .rub,
            currentOrderTypeFilter: .buy,
            c2cOrders: [
                C2CHistoryResponse.C2COrderTransformed(
                    orderNumber: "02394273598234599238523",
                    advNo: "84792837409127439234",
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
                    tradeType: .buy,
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
            ],
            c2cOrdersSecondType: [
                C2CHistoryResponse.C2COrderTransformed(
                    orderNumber: "02394273598234599238523",
                    advNo: "84792837409127439234",
                    tradeType: .sell,
                    asset: "USDT",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "8000000",
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
                    tradeType: .sell,
                    asset: "USDT",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "790000",
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
                    tradeType: .sell,
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
                    tradeType: .sell,
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
                    tradeType: .sell,
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
                    tradeType: .sell,
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
                    tradeType: .sell,
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
                    tradeType: .sell,
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
                    tradeType: .sell,
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
                    tradeType: .sell,
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
                    tradeType: .sell,
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
            ])
    }
}
