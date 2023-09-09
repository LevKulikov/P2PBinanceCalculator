//
//  FilterView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 06.08.2023.
//

import SwiftUI

struct FilterView: View {
    private enum DatePickerType {
        case oneDayPicker
        case rangeDatePicker
    }
    
    @Binding var orderType: C2CHistoryResponse.C2COrderType
    @Binding var orderStatus: C2CHistoryResponse.C2COrderStatus
    @Binding var orderFiat: C2CHistoryResponse.C2COrderFiat
    @Binding var orderAsset: C2CHistoryResponse.C2COrderAsset
    @Binding var fromDate: Date
    @Binding var toDate: Date
    @Binding var fromFiatValue: String
    @Binding var toFiatValue: String
    @Binding var orderAdvertisementRole: C2CHistoryResponse.C2COrderAdvertisementRole
    @State private var rotateArrowImage = false
    @State private var detailedFilterShow = false
    @State private var oneDaySet: Date = .now
    @State private var dateSetByPicker: DatePickerType = .rangeDatePicker
    @FocusState private var fromFiatTextField: Bool
    @FocusState private var toFiatTextField: Bool
    
    private var startDateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .month, value: -6, to: Date.now)!.startOfDay
        let max = toDate
        return min...max
    }
    private var endDateRange: ClosedRange<Date> {
        let min = fromDate
        //Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!
        let max = Date.now.endOfDay
        //> Calendar.current.date(byAdding: .day, value: 30, to: min)! ? Calendar.current.date(byAdding: .day, value: 30, to: min)! : Date.now
        return min...max
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Picker("Order type", selection: $orderType) {
                            ForEach(C2CHistoryResponse.C2COrderType.allCases, id: \.hashValue) {
                                Text($0.rawValue)
                                    .tag($0)
                            }
                        }
                        .buttonStyle(.bordered)
                        .padding(.leading, 15)
                        .id(1) // For ScrollViewReader proxy
                        
                        Picker("Order status", selection: $orderStatus) {
                            ForEach(C2CHistoryResponse.C2COrderStatus.allCases, id: \.hashValue) {
                                Text($0.humanName())
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
                        
                        if !detailedFilterShow {
                            DatePicker("Date to pick", selection: $oneDaySet, in: startDateRange.lowerBound...endDateRange.upperBound, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .padding(.leading, 10)
                                .applyTextColor(Color("binanceColor"))
                                .onTapGesture {
                                    dateSetByPicker = .oneDayPicker
                                }
                                .onChange(of: oneDaySet) {
                                    if dateSetByPicker == .oneDayPicker {
                                        fromDate = $0.startOfDay
                                        toDate = $0.endOfDay
                                    }
                                }
                                .transition(.offset(x: -50, y: 46).combined(with: .opacity))
                        }
                        
                        Button {
                            withAnimation {
                                detailedFilterShow.toggle()
                            }
                        } label: {
                            if detailedFilterShow {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6.5)
                                        .fill(Color("binanceColor"))
                                        .frame(width: 155, height: 34)
                                    HStack {
                                        Image(systemName: "chevron.up")
                                            .font(.title)
                                        
                                        Text("Hide")
                                    }
                                    .foregroundColor(Color(uiColor: .systemBackground))
                                }
                                .padding(.leading, 10)
                                .animation(.easeInOut, value: detailedFilterShow)
                            } else {
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.title)
                                    .foregroundColor(Color("binanceColor"))
                                    .rotationEffect(detailedFilterShow ? .degrees(-180) : .degrees(0))
                                    .animation(.easeInOut, value: detailedFilterShow)
                            }
                        }
                        .padding(.trailing, 15)
                        .accessibilityLabel("Button to open detailed filters")
                    }
                    
                    if detailedFilterShow {
                        VStack(alignment: .leading, spacing: 0) {
                            // First detailed filter row
                            HStack {
                                Picker("Order advertisement role", selection: $orderAdvertisementRole) {
                                    ForEach(C2CHistoryResponse.C2COrderAdvertisementRole.allCases, id: \.hashValue) {
                                        Text($0.rawValue)
                                            .tag($0)
                                    }
                                }
                                .buttonStyle(.bordered)
                                
                                DatePicker("From date", selection: $fromDate, in: startDateRange, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .applyTextColor(Color("binanceColor"))
                                    .padding(.leading, 10)
                                
                                Image(systemName: "arrowshape.right.fill")
                                    .foregroundColor(Color("binanceColor"))
                                    .imageScale(.large)
                                    .rotationEffect(.degrees(rotateArrowImage ? 360 : 0))
                                    .onTapGesture {
                                        withAnimation {
                                            rotateArrowImage.toggle()
                                        }
                                    }
                                
                                DatePicker("To date", selection: $toDate, in: endDateRange, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .applyTextColor(Color("binanceColor"))
                                    .onTapGesture {
                                        dateSetByPicker = .rangeDatePicker
                                    }
                                    .onChange(of: toDate) {
                                        if dateSetByPicker == .rangeDatePicker {
                                            oneDaySet = $0
                                        }
                                    }
                            }
                            .padding(.top, 10)
                            
                            // Second detailed filter row
                            HStack {
                                TextField(orderFiat != .allFiat ? "From \(orderFiat.rawValue) amount" : "Choose fiat", text: $fromFiatValue)
                                    .frame(width: 150)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .focused($fromFiatTextField)
                                    .disabled(orderFiat == .allFiat)
                                
                                Image(systemName: "arrowshape.right.fill")
                                    .foregroundColor(Color("binanceColor"))
                                    .imageScale(.large)
                                
                                TextField(orderFiat != .allFiat ? "To \(orderFiat.rawValue) amount" : "Choose fiat", text: $toFiatValue)
                                    .frame(width: 150)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .focused($toFiatTextField)
                                    .disabled(orderFiat == .allFiat)
                                    .padding(.trailing, 10)
                                    
                                Button("Default filters") {
                                    setFiltersToDefault()
                                    withAnimation {
                                        detailedFilterShow.toggle()
                                        proxy.scrollTo(1)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .foregroundColor(Color(uiColor: .systemBackground))
                            }
                            .padding(.top, 10)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    
                                    Button("Done") {
                                        fromFiatTextField = false
                                        toFiatTextField = false
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 15)
                        .transition(.push(from: .top))
                    }
                }
                .tint(Color("binanceColor"))
                .onTapGesture {
                    fromFiatTextField = false
                    toFiatTextField = false
                }
            }
        }
    }
    
    private func setFiltersToDefault() {
        orderType = .bothTypes
        orderStatus = .all
        orderFiat = .allFiat
        orderAsset = .allAssets
        dateSetByPicker = .rangeDatePicker
        fromDate = Calendar.current.date(byAdding: .day, value: -30, to: Date.now)!.startOfDay
        toDate = Date.now.endOfDay
        oneDaySet = toDate
        fromFiatValue = ""
        toFiatValue = ""
        orderAdvertisementRole = .bothRoles
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
            toDate: .constant(.now),
            fromFiatValue: .constant(""),
            toFiatValue: .constant(""),
            orderAdvertisementRole: .constant(.bothRoles)
        )
    }
}
