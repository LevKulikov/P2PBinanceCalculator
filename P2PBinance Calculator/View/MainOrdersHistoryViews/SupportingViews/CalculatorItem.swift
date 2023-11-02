//
//  CalculatorItem.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 07.08.2023.
//

import SwiftUI

struct CalculatorItem: View {
    var orders: [C2CHistoryResponse.C2COrderTransformed]
    private var ordersFiltered: [C2CHistoryResponse.C2COrderTransformed] {
        orders.filter { $0.activeForCount }
    }
    private var orderFiatSum: Float {
        ordersFiltered.compactMap { Float($0.totalPrice) }.reduce(0, +)
    }
    private var ordersContainsDefferentFiat: Bool {
        guard let firstOrder = orders.first, orders.count != 1 else {
            return false
        }
        
        return orders.contains { $0.fiat != firstOrder.fiat }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Total orders: ").bold() + Text("\(ordersFiltered.count)")
            if !ordersContainsDefferentFiat {
                if !orders.isEmpty {
                    Text("Total sum \(orders.first!.fiat): ").bold() + Text("\(orderFiatSum.currencyRU)")
                } else {
                    Text("No orders").bold()
                }
            } else {
                Text("Filter orders with same fiat").bold()
            }
        }
        .font(.title2)
    }
}

struct CalculatorItem_Previews: PreviewProvider {
    static let orders = [
        C2CHistoryResponse.C2COrderTransformed(
            orderNumber: "02394273598234599238523",
            advNo: "84792837409127439234",
            tradeType: .buy,
            asset: "USDT",
            fiat: "RUB",
            fiatSymbol: "₽",
            amount: "7841.0842534200",
            totalPrice: "745000",
            unitPrice: "95.5",
            orderStatus: .inAppeal,
            createTime: 1619361369000,
            commission: "0",
            counterPartNickName: "ab***",
            advertisementRole: .taker
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
            advertisementRole: .taker
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
            advertisementRole: .taker
            
        ),
        C2CHistoryResponse.C2COrderTransformed(
            orderNumber: "8327491840123984",
            advNo: "84792837409127439234",
            tradeType: .buy,
            asset: "USDT",
            fiat: "RUB",
            fiatSymbol: "₽",
            amount: "7841.0842534200",
            totalPrice: "750000",
            unitPrice: "95.5",
            orderStatus: .cancelled,
            createTime: 1619361369000,
            commission: "0",
            counterPartNickName: "ab***",
            advertisementRole: .taker
        ),
        C2CHistoryResponse.C2COrderTransformed(
            orderNumber: "43987209347150823403",
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
            advertisementRole: .taker
        ),
        C2CHistoryResponse.C2COrderTransformed(
            orderNumber: "43987209347150823413",
            advNo: "84792837409127439234",
            tradeType: .buy,
            asset: "USDT",
            fiat: "RUB",
            fiatSymbol: "₽",
            amount: "7841.0842534200",
            totalPrice: "750000",
            unitPrice: "95.5",
            orderStatus: .cancelledBySystem,
            createTime: 1619361369000,
            commission: "0",
            counterPartNickName: "ab***",
            advertisementRole: .taker
        ),
        C2CHistoryResponse.C2COrderTransformed(
            orderNumber: "43987209347950823403",
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
            advertisementRole: .taker
        ),
        C2CHistoryResponse.C2COrderTransformed(
            orderNumber: "33987209347950823403",
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
            advertisementRole: .taker
        ),
        C2CHistoryResponse.C2COrderTransformed(
            orderNumber: "23987209347950823403",
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
            advertisementRole: .taker
        ),
        C2CHistoryResponse.C2COrderTransformed(
            orderNumber: "53987209347950823403",
            advNo: "84792837409127439234",
            tradeType: .sell,
            asset: "USDT",
            fiat: "RUB",
            fiatSymbol: "₽",
            amount: "7841.0842534200",
            totalPrice: "650000",
            unitPrice: "95.5",
            orderStatus: .completed,
            createTime: 1619361369000,
            commission: "0",
            counterPartNickName: "ab***",
            advertisementRole: .taker
        )
    ]
    
    static var previews: some View {
        CalculatorItem(orders: CalculatorItem_Previews.orders)
    }
}
