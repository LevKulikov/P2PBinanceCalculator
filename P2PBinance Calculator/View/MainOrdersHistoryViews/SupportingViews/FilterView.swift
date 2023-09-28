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
    @Binding var customFiat: String
    @Binding var customAsset: String
    @Binding var fromDate: Date
    @Binding var toDate: Date
    @Binding var fromFiatValue: String
    @Binding var toFiatValue: String
    @Binding var orderAdvertisementRole: C2CHistoryResponse.C2COrderAdvertisementRole
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var rotateArrowImage = false
    @State private var detailedFilterShow = false
    @State private var oneDaySet: Date = .now
    @State private var dateSetByPicker: DatePickerType = .rangeDatePicker
    @FocusState private var customFiatTextField: Bool
    @FocusState private var customAssetTextField: Bool
    @FocusState private var fromFiatTextField: Bool
    @FocusState private var toFiatTextField: Bool
    
    private var showSecondRow: Bool {
        return settingsViewModel.publishedRoleFilterShow || settingsViewModel.publishedDateRangeFilterShow
    }
    
    private var showThirdRow: Bool {
        if settingsViewModel.publishedDateRangeFilterShow && settingsViewModel.publishedAmountFilterShow {
            return true
        } else if settingsViewModel.publishedDateRangeFilterShow && settingsViewModel.publishedRoleFilterShow {
            return true
        } else if !settingsViewModel.publishedDateRangeFilterShow && !settingsViewModel.publishedRoleFilterShow && settingsViewModel.publishedAmountFilterShow {
            return true
        } else {
            return false
        }
    }
    
    private let fiatExampleArray = ["GBP", "CNY", "JPY", "KZT", "NGN", "AZN"]
    private let assetExampleArray = ["C98", "DOT", "ADA", "XRP", "SOL", "DAI"]
    
    private var startDateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .month, value: -6, to: Date.now)!.startOfDay
        let max = toDate
        return min...max
    }
    private var endDateRange: ClosedRange<Date> {
        let min = fromDate
        let max = Date.now.endOfDay
        return min...max
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    getScrollableFirstFilterRow(proxy: proxy)
                    
                    if detailedFilterShow {
                        VStack(alignment: .leading, spacing: 0) {
                            if showSecondRow {
                                getScrollableSecondFilterRow(proxy: proxy)
                                    .padding(.top, 10)
                            }
                            
                            if showThirdRow {
                                getScrollableThirdFilterRow(proxy: proxy)
                                    .padding(.top, 10)
                            }
                        }
                        .padding(.horizontal, 15)
                        .transition(.push(from: .top))
                    }
                }
                .tint(SettingsStorage.pickedAppColor)
                .onTapGesture {
                    unfocuseTextFields()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        Button("Done") {
                            unfocuseTextFields()
                        }
                    }
                }
            }
        }
    }
    
    private var showHideDetailedFiltersButton: some View {
        Button {
            withAnimation {
                detailedFilterShow.toggle()
            }
        } label: {
            if detailedFilterShow {
                ZStack {
                    RoundedRectangle(cornerRadius: 6.5)
                        .fill(SettingsStorage.pickedAppColor)
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
                    .foregroundColor(SettingsStorage.pickedAppColor)
                    .rotationEffect(detailedFilterShow ? .degrees(-180) : .degrees(0))
                    .animation(.easeInOut, value: detailedFilterShow)
            }
        }
        .accessibilityLabel("Button to open detailed filters")
    }
    
    @ViewBuilder
    private func getScrollableFirstFilterRow(proxy: ScrollViewProxy) -> some View {
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
            
            Picker("Order fiat", selection: $orderFiat.animation(.easeInOut)) {
                ForEach(C2CHistoryResponse.C2COrderFiat.allCases, id: \.hashValue) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .buttonStyle(.bordered)
            
            if orderFiat == .custom {
                TextField("ex. \(fiatExampleArray.randomElement()!)", text: $customFiat)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($customFiatTextField)
                    .disabled(orderFiat != .custom)
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .padding(.trailing, 10)
            }
            
            Picker("Order asset", selection: $orderAsset.animation(.easeInOut)) {
                ForEach(C2CHistoryResponse.C2COrderAsset.allCases, id: \.hashValue) {
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .buttonStyle(.bordered)
            
            if orderAsset == .custom {
                TextField("ex. \(assetExampleArray.randomElement()!)", text: $customAsset)
                    .frame(width: 80)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($customAssetTextField)
                    .disabled(orderAsset != .custom)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            if !detailedFilterShow {
                DatePicker("Date to pick", selection: $oneDaySet, in: startDateRange.lowerBound...endDateRange.upperBound, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .padding(.leading, 10)
                    .applyTextColor(SettingsStorage.pickedAppColor)
                    .onTapGesture {
                        dateSetByPicker = .oneDayPicker
                    }
                    .onChange(of: oneDaySet) {
                        if dateSetByPicker == .oneDayPicker {
                            fromDate = $0.startOfDay
                            toDate = $0.endOfDay
                        }
                    }
                    .onAppear {
                        oneDaySet = toDate.endOfDay
                    }
                    .transition(.offset(x: -50, y: 46).combined(with: .opacity))
            }
            
            if showSecondRow || showThirdRow {
                showHideDetailedFiltersButton
                    .padding(.trailing, 15)
            } else {
                scrollableDefualtFiltersButton(proxy: proxy)
                    .padding(.trailing, 15)
            }
        }
    }
    
    @ViewBuilder
    private func getScrollableSecondFilterRow(proxy: ScrollViewProxy) -> some View {
        HStack {
            if settingsViewModel.publishedRoleFilterShow {
                Picker("Order advertisement role", selection: $orderAdvertisementRole) {
                    ForEach(C2CHistoryResponse.C2COrderAdvertisementRole.allCases, id: \.hashValue) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                .buttonStyle(.bordered)
            }
            
            if settingsViewModel.publishedDateRangeFilterShow {
                DatePicker("From date", selection: $fromDate, in: startDateRange, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .applyTextColor(SettingsStorage.pickedAppColor)
                    .padding(.leading, settingsViewModel.publishedRoleFilterShow ? 10 : 0)
                
                Image(systemName: "arrowshape.right.fill")
                    .foregroundColor(SettingsStorage.pickedAppColor)
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
                    .applyTextColor(SettingsStorage.pickedAppColor)
                    .onTapGesture {
                        dateSetByPicker = .rangeDatePicker
                    }
                    .onChange(of: toDate) {
                        if dateSetByPicker == .rangeDatePicker {
                            oneDaySet = $0
                        }
                    }
            } else if settingsViewModel.publishedRoleFilterShow {
                getScrollableThirdFilterRow(proxy: proxy)
            }
            
            if !settingsViewModel.publishedRoleFilterShow && settingsViewModel.publishedDateRangeFilterShow && !settingsViewModel.publishedAmountFilterShow {
                scrollableDefualtFiltersButton(proxy: proxy)
            }
        }
    }
    
    @ViewBuilder
    private func getScrollableThirdFilterRow(proxy: ScrollViewProxy) -> some View {
        HStack {
            if settingsViewModel.publishedAmountFilterShow {
                TextField(orderFiat != .allFiat ? "From \(orderFiat != .custom ? orderFiat.rawValue : customFiat) amount" : "Choose fiat", text: $fromFiatValue)
                    .frame(width: 150)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .focused($fromFiatTextField)
                    .disabled(orderFiat == .allFiat)
                
                Image(systemName: "arrowshape.right.fill")
                    .foregroundColor(SettingsStorage.pickedAppColor)
                    .imageScale(.large)
                
                TextField(orderFiat != .allFiat ? "To \(orderFiat != .custom ? orderFiat.rawValue : customFiat) amount" : "Choose fiat", text: $toFiatValue)
                    .frame(width: 150)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .focused($toFiatTextField)
                    .disabled(orderFiat == .allFiat)
                    .padding(.trailing, 10)
            }
            
            scrollableDefualtFiltersButton(proxy: proxy)
        }
    }
    
    @ViewBuilder
    private func scrollableDefualtFiltersButton(proxy: ScrollViewProxy) -> some View {
        Button("Default filters") {
            setFiltersToDefault()
            withAnimation {
                detailedFilterShow.toggle()
                proxy.scrollTo(1)
            }
        }
        .buttonStyle(.borderedProminent)
        .foregroundColor(Color(uiColor: .systemBackground))
        .fixedSize()
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
    
    private func unfocuseTextFields() {
        customFiatTextField = false
        customAssetTextField = false
        fromFiatTextField = false
        toFiatTextField = false
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            orderType: .constant(.buy),
            orderStatus: .constant(.cancelled),
            orderFiat: .constant(.allFiat),
            orderAsset: .constant(.allAssets),
            customFiat: .constant(""),
            customAsset: .constant(""),
            fromDate: .constant(Calendar.current.date(byAdding: .month, value: -5, to: Date.now)!),
            toDate: .constant(.now),
            fromFiatValue: .constant(""),
            toFiatValue: .constant(""),
            orderAdvertisementRole: .constant(.bothRoles)
        )
        .environmentObject(SettingsViewModel(settingsStorage: SettingsStorageMock()))
    }
}
