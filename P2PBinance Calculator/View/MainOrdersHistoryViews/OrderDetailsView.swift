//
//  OrderDetailsView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 11.08.2023.
//

import SwiftUI

struct OrderDetailsView: View {
    let order: C2CHistoryResponse.C2COrderTransformed
    @Environment(\.openURL) private var openUrl
    @State private var isCopied: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("\(order.tradeType.rawValue) \(order.asset)")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(order.tradeType == .buy ? Color.green : Color.red)
                            
                            Text(order.createTime.formatted())
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Text(order.orderStatus.humanName())
                                .font(.title3)
                                .foregroundColor(C2CHistoryResponse.C2COrderStatus.basicStatus.contains(order.orderStatus) ? .gray : .red)
                        }
                        
                        Spacer()
                        
                        Image(order.asset)
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    .padding(.bottom)
                    
                    HStack(spacing: 0) {
                        Text("Price: ")
                            .bold()
                        Text(order.unitPrice.currencyRU)
                            .textSelection(.enabled)
                            
                    }
                    .font(.title3)
                    .padding(.bottom)
                    
                    HStack(spacing: 0) {
                        Text("Amount \(order.asset): ")
                            .bold()
                        Text(order.amount.currencyRU)
                            .textSelection(.enabled)
                    }
                    .font(.title3)
                    .padding(.bottom)
                    
                    HStack(spacing: 0) {
                        Text("For \(order.fiat): ")
                            .bold()
                        Text("\(order.totalPrice.currencyRU) \(order.fiatSymbol)")
                            .textSelection(.enabled)
                    }
                    .font(.title3)
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Number: ")
                                .bold()
                            Text(order.orderNumber)
                                .underline(color: .gray)
                                .lineLimit(0...1)
                                .truncationMode(.head)
                        }
                        .font(.title3)
                        .padding(.bottom)
                        .onTapGesture {
                            copyAsPlainText(order.orderNumber)
                            showCopyIndicator()
                        }
                        
                        HStack(spacing: 0) {
                            Text("Adv. №: ")
                                .bold()
                            Text(order.advNo)
                                .underline(color: .gray)
                                .lineLimit(0...1)
                                .truncationMode(.head)
                        }
                        .font(.title3)
                        .padding(.bottom)
                        .onTapGesture {
                            copyAsPlainText(order.advNo)
                            showCopyIndicator()
                        }
                        
                        HStack(spacing: 0) {
                            Text("Order role: ")
                                .bold()
                            Text(order.advertisementRole.rawValue)
                        }
                        .font(.title3)
                        .padding(.bottom)
                        
                        
                        HStack(spacing: 0) {
                            Text("Counterpart: ")
                                .bold()
                            Text(order.counterPartNickName)
                        }
                        .font(.title3)
                        .padding(.bottom)
                        
                        HStack(spacing: 0) {
                            Text("Commission: ")
                                .bold()
                            Text(
                                order.commission == 0 ? "0" : "\(order.commission.currencyRU) \(order.asset) / \((order.commission * order.unitPrice).currencyRU) \(order.fiat)"
                            )
                        }
                        .font(.title3)
                        .padding(.bottom)
                    }
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
//                .navigationTitle("Order details")
                .toolbar {
                    Menu {
                        Button {
                            copyAsPlainText("https://p2p.binance.com/ru/fiatOrderDetail?orderNo=\(order.advNo)")
                        } label: {
                            Label("Copy order link", systemImage: "doc.on.doc")
                        }
                    } label: {
                        Image(systemName: "globe")
                            .font(.custom("title1.5", size: 25))
                            .cornerRadius(15)
                            .foregroundColor(SettingsStorage.pickedAppColor)
                    } primaryAction: {
                        openUrl(URL(string: "https://p2p.binance.com/ru/fiatOrderDetail?orderNo=\(order.orderNumber)") ?? URL(string: "https://www.binance.com/")!)
                    }

                }
                .padding()
            }
            
            if isCopied {
                Text("Copied successfully")
                    .foregroundColor(.gray)
                    .padding(.all, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 4)
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private func showCopyIndicator() {
        withAnimation {
            isCopied = true
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.6) {
            withAnimation {
                isCopied = false
            }
        }
    }
}

struct OrderDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderDetailsView(
                order: C2CHistoryResponse.C2COrderTransformed(
                    orderNumber: "532309572393570923",
                    advNo: "473823942304729830452",
                    tradeType: .buy,
                    asset: "USDT",
                    fiat: "RUB",
                    fiatSymbol: "ru",
                    amount: "6000",
                    totalPrice: "750000",
                    unitPrice: "96.6",
                    orderStatus: .completed,
                    createTime: 1619361369000,
                    commission: "5",
                    counterPartNickName: "fiz***",
                    advertisementRole: .taker
                )
            )
        }
    }
}
