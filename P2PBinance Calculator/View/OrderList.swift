//
//  OrderList.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 06.08.2023.
//

import SwiftUI

struct OrderList: View {
    var orders: [C2CHistoryResponse.C2COrderTransformed]
    
    var body: some View {
        List {
            ForEach(orders) { order in
                OrderItem(order: order)
            }
        }
        .onAppear {
            UIRefreshControl.appearance().tintColor = UIColor(named: "binanceColor")
        }
        .listStyle(.inset)
        .navigationTitle("P2P Orders")
        .animation(.default, value: orders)
    }
}

struct OrderList_Previews: PreviewProvider {
    static var previews: some View {
        OrderList(orders: [
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
                orderNumber: "02394273598234599238523",
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
                orderNumber: "02394273598234599238523",
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
                
            )
        ])
    }
}
