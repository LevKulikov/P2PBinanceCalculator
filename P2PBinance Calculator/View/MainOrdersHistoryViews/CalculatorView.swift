//
//  StatisticsView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 08.08.2023.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    //MARK: Properties
    // Init properties
    var currentOrderFiat: C2CHistoryResponse.C2COrderFiat
    var currentCustomFiat: String
    var currentOrderTypeFilter: C2CHistoryResponse.C2COrderType
    var startDate: Date
    var endDate: Date
    var c2cOrders: [C2CHistoryResponse.C2COrderTransformed]
    var c2cOrdersSecondType: [C2CHistoryResponse.C2COrderTransformed]
    // Property wrappers
    @State private var pickerSelection: String = ""
    // To use in calculations
    private var c2cOrdersCompleted: [C2CHistoryResponse.C2COrderTransformed] {
        return c2cOrders.filter { $0.orderStatus == .completed && $0.activeForCount }
    }
    private var c2cOrdersSecondTypeCompleted: [C2CHistoryResponse.C2COrderTransformed] {
        return c2cOrdersSecondType.filter { $0.orderStatus == .completed && $0.activeForCount }
    }
    // Calculations
    private var firstOrdersValue: Float {
        c2cOrdersCompleted.map { $0.totalPrice }.reduce(0, +)
    }
    private var secondOrdersValue: Float {
        c2cOrdersSecondTypeCompleted.map { $0.totalPrice }.reduce(0, +)
    }
    private var firstOrdersCommissionFiat: Float {
        c2cOrdersCompleted.map {
            $0.commission * $0.unitPrice
        }.reduce(0, +)
    }
    private var secondOrdersCommissionFiat: Float {
        c2cOrdersSecondTypeCompleted.map {
            $0.commission * $0.unitPrice
        }.reduce(0, +)
    }
    /// Sell orders minus buy orders
    private var ordersProfit: Float {
        if currentOrderTypeFilter == .buy || currentOrderTypeFilter == .bothTypes {
            return secondOrdersValue - firstOrdersValue
        } else {
            return firstOrdersValue - secondOrdersValue
        }
    }
    /// Sell orders devide for buy orders spread
    private var ordersSpread: Float {
        if currentOrderTypeFilter == .buy || currentOrderTypeFilter == .bothTypes {
            return (secondOrdersValue/firstOrdersValue-1)*100
        } else {
            return (firstOrdersValue/secondOrdersValue-1)*100
        }
    }
    /// Retruns unique assets mentioned in orders
    private var assetsInOrders: [String] {
        let assets = (c2cOrdersCompleted + c2cOrdersSecondTypeCompleted).map { $0.asset }
        return Array(Set(assets).sorted(by: >))
    }
    /// Order array which is used in chart
    private var chartOrders: [C2CHistoryResponse.C2COrderTransformed] {
        let orders = (c2cOrdersCompleted + c2cOrdersSecondTypeCompleted).sorted { $0.createTime < $1.createTime }
        if assetsInOrders.count > 1 {
            return orders.filter { $0.asset == pickerSelection }
        }
        return orders
    }
    /// Price range from minimum price minus 1 and maximum price plus 1
    private var priceRange: ClosedRange<Int> {
        let allPrices = chartOrders.map { $0.unitPrice }
        let minPrice = allPrices.min() ?? 0 == 0 ? 0 : allPrices.min()! - 1
        let maxPrice = (allPrices.max() ?? 0) + 1
        return Int(minPrice)...Int(maxPrice)
    }
    
    private var textToShare: String {
        """
        My P2P orders results \(startDate.startOfDay == endDate.startOfDay ? "for \(endDate.formatted(date: .numeric, time: .omitted))" : "from \(startDate.formatted(date: .numeric, time: .omitted)) to \(endDate.formatted(date: .numeric, time: .omitted))"):
        Value - \((firstOrdersValue + secondOrdersValue).currencyRU) \(c2cOrders.first?.fiatSymbol ?? "")
        Profit - \(ordersProfit.currencyRU) \(c2cOrders.first?.fiatSymbol ?? "")
        Medium spread - \(ordersSpread.currencyRU)%
        
        P2P Calculator helped me to calculate it in couple clicks 😜
        """
    }
    
    //MARK: Body
    var body: some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            craateViewForStatistics()
                .presentationDetents([.height(215), .large])
                .presentationBackground(.clear)
        } else {
            craateViewForStatistics()
        }
    }
    
    private var tradeValueText: some View {
        HStack(spacing: 0) {
            Text("Value \(currentOrderFiat != .custom ? currentOrderFiat.rawValue : currentCustomFiat): ")
            Text((firstOrdersValue + secondOrdersValue).currencyRU).underline(color: .gray)
                .contextMenu {
                    Button {
                        copyAsPlainText((firstOrdersValue + secondOrdersValue).currencyRU)
                    } label: {
                        Label("Copy total value", systemImage: "doc.on.doc")
                    }
                } preview: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Buy ")
                                .foregroundColor(.green)
                            Text(currentOrderTypeFilter == .buy ? firstOrdersValue.currencyRU : secondOrdersValue.currencyRU)
                        }
                        HStack {
                            Text("Sell ")
                                .foregroundColor(.red)
                            Text(currentOrderTypeFilter == .buy ? secondOrdersValue.currencyRU : firstOrdersValue.currencyRU)
                        }
                    }
                    .font(.title2)
                    .padding()
                }
        }
    }
    
    private var tradeProfitText: some View {
        HStack(spacing: 0) {
            Text("Profit: ")
            Text(ordersProfit.currencyRU).underline(color: .gray)
                .contextMenu {
                    Button {
                        copyAsPlainText(ordersProfit.currencyRU)
                    } label: {
                        Label("Copy profit", systemImage: "doc.on.doc")
                    }
                } preview: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Buy ")
                                .foregroundColor(.green)
                            Text(currentOrderTypeFilter == .buy ? firstOrdersValue.currencyRU : secondOrdersValue.currencyRU)
                        }
                        HStack {
                            Text("Sell ")
                                .foregroundColor(.red)
                            Text(currentOrderTypeFilter == .buy ? secondOrdersValue.currencyRU : firstOrdersValue.currencyRU)
                        }
                        HStack {
                            Text("Commission ")
                                .foregroundColor(.gray)
                            Text((firstOrdersCommissionFiat + secondOrdersCommissionFiat).currencyRU)
                        }
                    }
                    .font(.title2)
                    .padding()
                }
        }
    }
    
    private var mediumSpreadText: some View {
        HStack(spacing: 0) {
            Text("Medium spread: ")
            Text("\(ordersSpread.currencyRU)%").underline(color: .gray)
                .contextMenu {
                    Button {
                        copyAsPlainText("\(ordersSpread.currencyRU)%")
                    } label: {
                        Label("Copy spread %", systemImage: "doc.on.doc")
                    }
                } preview: {
                    VStack {
                        HStack {
                            Text("Sell ")
                                .foregroundColor(.red)
                            Text(currentOrderTypeFilter == .buy ? secondOrdersValue.currencyRU : firstOrdersValue.currencyRU)
                                
                        }
                        .font(.title2)
                        
                        Text("/")
                            .font(.title)
                            .rotationEffect(.degrees(45))
                        
                        HStack {
                            Text("Buy ")
                                .foregroundColor(.green)
                            Text(currentOrderTypeFilter == .buy ? firstOrdersValue.currencyRU : secondOrdersValue.currencyRU)
                        }
                        .font(.title2)
                    }
                    .padding()
                }
        }
    }
    
    private var chartView: some View {
        VStack {
            Chart {
                ForEach(chartOrders) { order in
                    LineMark(
                        x: .value("Date of a price", order.createTime, unit: .second),
                        y: .value("Price", order.unitPrice)
                    )
                    .foregroundStyle(by: .value("Order type", "\(order.tradeType.rawValue) Price"))
                    .symbol(.circle)
                    .symbolSize(15)
                }
            }
            .chartYScale(domain: priceRange)
            .frame(height: 250)
            .animation(.easeOut, value: pickerSelection)
            
            if assetsInOrders.count > 1 {
                AssetPicker(assets: assetsInOrders, pickerSelection: $pickerSelection)
                    .onAppear {
                        pickerSelection = assetsInOrders.first!
                    }
            }
        }
    }
    
    private var disclaimerText: some View {
        VStack(alignment: .leading) {
            Text("Only completed orders are counted.")
            Text("Ordes value = buy + sell orders.")
            Text("Profit calculation takes into account commission costs.")
            Text("Errors are possible if there were buy orders without subsequent sale and vice versa!").bold()
        }
    }
    
    //MARK: Methods
    @ViewBuilder
    private func craateViewForStatistics() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("Statistics")
                        .font(.largeTitle)
                        .bold()
                    
                    Spacer()
                    
                    ShareLink(item: textToShare) {
                        Image(systemName: "square.and.arrow.up.circle")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .bottomTrailing)
                            .foregroundColor(SettingsStorage.pickedAppColor)
                    }
                }
                .padding(.top)
                .padding(.bottom)
                
                tradeValueText
                    .font(.title2)
                    .padding(.bottom, 1)
                
                tradeProfitText
                    .font(.title2)
                    .padding(.bottom, 1)
                
                if firstOrdersValue != 0 && secondOrdersValue != 0 {
                    mediumSpreadText
                        .font(.title2)
                        .padding(.bottom)
                }
                
                
                chartView
                    .padding(.bottom)
                
                disclaimerText
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
        )
//        .ignoresSafeArea(edges: .bottom)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(
            currentOrderFiat: .rub,
            currentCustomFiat: "CNY",
            currentOrderTypeFilter: .buy,
            startDate: Date.now.dayBefore,
            endDate: Date.now,
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
                    asset: "ADA",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "750000",
                    unitPrice: "900.5",
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
                    asset: "BTC",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "750000",
                    unitPrice: "1500000",
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
                    asset: "BTC",
                    fiat: "UAH",
                    fiatSymbol: "U₽",
                    amount: "7841.0842534200",
                    totalPrice: "750000",
                    unitPrice: "750000",
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
                    fiat: "AZT",
                    fiatSymbol: "G₽",
                    amount: "7841.0842534200",
                    totalPrice: "300",
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
                    asset: "LTC",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "750000",
                    unitPrice: "0.01",
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
                    asset: "BUSD",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "750000",
                    unitPrice: "94.5",
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
                    asset: "BNB",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "750000",
                    unitPrice: "30000",
                    orderStatus: .completed,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
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
                    unitPrice: "500000",
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
                    asset: "RUB",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "750000",
                    unitPrice: "1.01",
                    orderStatus: .completed,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
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
                    advertisementRole: .taker
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
                    advertisementRole: .taker
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
                    advertisementRole: .taker
                    
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
                    unitPrice: "1600000",
                    orderStatus: .cancelled,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
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
                    unitPrice: "800000",
                    orderStatus: .completed,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
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
                    unitPrice: "350",
                    orderStatus: .cancelledBySystem,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
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
                    unitPrice: "0.02",
                    orderStatus: .completed,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
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
                    unitPrice: "93.5",
                    orderStatus: .completed,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
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
                    unitPrice: "35000",
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
                    asset: "ETH",
                    fiat: "RUB",
                    fiatSymbol: "₽",
                    amount: "7841.0842534200",
                    totalPrice: "750000",
                    unitPrice: "550000",
                    orderStatus: .completed,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
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
                    unitPrice: "1",
                    orderStatus: .completed,
                    createTime: 1619361369000,
                    commission: "0",
                    counterPartNickName: "ab***",
                    advertisementRole: .taker
                ),
            ])
    }
}
