//
//  OrderItem.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import SwiftUI

struct OrderItem: View {
    let order: C2CHistoryResponse.C2COrderTransformed
    private var orderAmountAsset: Float {
        Float(Int(Float(order.amount)! * 100)) / 100
    }
    private var orderTotalPrice: Float {
        Float(Int(Float(order.totalPrice)! * 100)) / 100
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                
                Text(order.tradeType.rawValue)
                    .font(.title2)
                    .bold()
                    .foregroundColor(order.tradeType == .buy ? Color.green : Color.red)
                Text(" \(orderAmountAsset.currencyRU) \(order.asset)")
                    .font(.title3)
                
                Spacer()
                
                Image(order.asset)
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    ( Text("For ").bold() + Text(orderTotalPrice.currencyRU) + Text(" \(order.fiat)") )
                        .font(.title3)
                    
                    ( Text("Price: ").bold() + Text(Float(order.unitPrice)?.currencyRU ?? "NaN") )
                        .font(.title3)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(order.orderStatus.rawValue)
                        .font(C2CHistoryResponse.C2COrderStatus.basicStatus.contains(order.orderStatus) ? .footnote : .title2)
                        .foregroundColor(C2CHistoryResponse.C2COrderStatus.basicStatus.contains(order.orderStatus) ? .gray : .red)
                    
                    Text(Date(timeIntervalSince1970: TimeInterval(order.createTime / 1000)), style: .date)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
        .opacity(order.activeForCount ? 1 : 0.3)
    }
}

struct OrderItem_Previews: PreviewProvider {
    static var previews: some View {
        OrderItem(
            order: C2CHistoryResponse.C2COrderTransformed(
                orderNumber: "02394273598234599238523",
                advNo: "84792837409127439234",
                tradeType: .buy,
                asset: "USDT",
                fiat: "RUB",
                fiatSymbol: "₽",
                amount: "7841.0842534200",
                totalPrice: "750000",
                unitPrice: "95.5",
                orderStatus: .cancelled,
                createTime: 1691334624000,
                commission: "0",
                counterPartNickName: "ab***",
                advertisementRole: "TAKER"
            )
        )
    }
}
