//
//  FilterView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 06.08.2023.
//

import SwiftUI

struct FilterView: View {
    @Binding var orderType: C2CHistoryResponse.C2COrderType
    @Binding var orderStatus: C2CHistoryResponse.C2COrderStatus
    @Binding var orderFiat: C2CHistoryResponse.C2COrderFiat
    @Binding var orderAsset: C2CHistoryResponse.C2COrderAsset
    @Binding var fromDate: Date
    @Binding var toDate: Date
    @State private var rotateArrowImage = false
    
    private var startDateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .month, value: -6, to: Date.now)!.startOfDay
        let max = toDate.startOfDay
        return min...max
    }
    private var endDateRange: ClosedRange<Date> {
        let min = fromDate.startOfDay
        //Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!
        let max = Date.now
        //> Calendar.current.date(byAdding: .day, value: 30, to: min)! ? Calendar.current.date(byAdding: .day, value: 30, to: min)! : Date.now
        return min...max
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Picker("Order type", selection: $orderType) {
                        ForEach(C2CHistoryResponse.C2COrderType.allCases, id: \.hashValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .buttonStyle(.bordered)
                    .id(1)
                    .padding(.leading, 15)
                    
                    Picker("Order status", selection: $orderStatus) {
                        ForEach(C2CHistoryResponse.C2COrderStatus.allCases, id: \.hashValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Picker("Order fiat", selection: $orderFiat) {
                        ForEach(C2CHistoryResponse.C2COrderFiat.allCases, id: \.hashValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Picker("Order asset", selection: $orderAsset) {
                        ForEach(C2CHistoryResponse.C2COrderAsset.allCases, id: \.hashValue) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    DatePicker("From date", selection: $fromDate, in: startDateRange, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .padding(.leading, 10)
                        .applyTextColor(Color("binanceColor"))
                    
                    Image(systemName: "arrowshape.right.fill")
                        .foregroundColor(Color("binanceColor"))
                        .imageScale(.large)
                        .rotationEffect(.degrees(rotateArrowImage ? 360 : 0))
                        .onTapGesture {
                            withAnimation {
                                rotateArrowImage.toggle()
                            }
                        }
                    
                    DatePicker("To date", selection: $toDate, in: endDateRange, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .padding(.trailing, 10)
                        .applyTextColor(Color("binanceColor"))
                    
                    Button("Default filters") {
                        setFiltersToDefault()
                        withAnimation {
                            proxy.scrollTo(1)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 15)
                }
                .tint(Color("binanceColor"))
            }
        }
    }
    
    private func setFiltersToDefault() {
        orderType = .bothTypes
        orderStatus = .all
        orderFiat = .allFiat
        orderAsset = .allAssets
        fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date.now)!
        toDate = Date.now
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            orderType: .constant(.buy),
            orderStatus: .constant(.cancelled),
            orderFiat: .constant(.allFiat),
            orderAsset: .constant(.allAssets),
            fromDate: .constant(Calendar.current.date(byAdding: .month, value: -5, to: Date.now)!),
            toDate: .constant(.now)
        )
    }
}
