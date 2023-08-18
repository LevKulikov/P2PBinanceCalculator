//
//  ContentView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import SwiftUI

struct ContentView: View {
    //MARK: - Properties
    //MARK: Environment and state props
    @EnvironmentObject var viewModel: GeneralViewModel
    @State private var buttonDidLoad = false
    @State private var loadStatus = (isLoading: false, isResponseGet: false)
    @State private var responseError: BinanceConnection.BinanceError? = nil
    @State private var errorFlag = false
    @State private var isCalculatorButtonActive = false 
    @State private var presentCalculatorSheet = false
    @State private var presentAPISheet = false
    @State private var presentCalculatorError = false
    @State private var didChangeAPI = false
    @State private var c2cOrders: [C2CHistoryResponse.C2COrderTransformed] = []
    /// If c2cOrders is buy, c2cOrdersSecondType is sell, and vise versa
    @State private var c2cOrdersSecondType: [C2CHistoryResponse.C2COrderTransformed] = []
    
    //    @State private var selectedC2COrders: [C2CHistoryResponse.C2COrderTransformed] = []
    
    //MARK: Filtering props
    @State private var orderType: C2CHistoryResponse.C2COrderType = .bothTypes
    @State private var orderStatus: C2CHistoryResponse.C2COrderStatus = .all
    @State private var orderFiat: C2CHistoryResponse.C2COrderFiat = .allFiat
    @State private var orderAsset: C2CHistoryResponse.C2COrderAsset = .allAssets
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date.now)!
    @State private var endDate = Date.now
    
    //MARK: Computed props
    // Filters c2cOrders according to filter settings
    private var c2cOrdersFiltered: [C2CHistoryResponse.C2COrderTransformed] {
        var statusFiltered = c2cOrders
        if orderStatus != .all {
            statusFiltered = statusFiltered.filter { $0.orderStatus == orderStatus }
        }
        
        var fiatFiltered = statusFiltered
        if orderFiat != .allFiat {
            if orderFiat == .other {
                fiatFiltered = fiatFiltered.filter { order in
                    !C2CHistoryResponse.C2COrderFiat
                        .mentionedFiat
                        .contains { fiat in
                            order.fiat == fiat.rawValue
                        }
                }
            } else {
                fiatFiltered = fiatFiltered.filter { $0.fiat == orderFiat.rawValue }
            }
        }
        
        var assetFiltered = fiatFiltered
        if orderAsset != .allAssets {
            if orderAsset == .other {
                assetFiltered = assetFiltered.filter { order in
                    !C2CHistoryResponse.C2COrderAsset
                        .mentionedAssets
                        .contains { asset in
                            order.asset == asset.rawValue
                        }
                }
            } else {
                assetFiltered = assetFiltered.filter { $0.asset == orderAsset.rawValue }
            }
        }
        
        return assetFiltered
    }
    
    // Filters c2cOrdersSecond according to filter settings
    private var c2cOrdersSecondTypeFiltered: [C2CHistoryResponse.C2COrderTransformed] {
        var statusFiltered = c2cOrdersSecondType
        if orderStatus != .all {
            statusFiltered = statusFiltered.filter { $0.orderStatus == orderStatus }
        }
        
        var fiatFiltered = statusFiltered
        if orderFiat != .allFiat {
            if orderFiat == .other {
                fiatFiltered = fiatFiltered.filter { order in
                    !C2CHistoryResponse.C2COrderFiat
                        .mentionedFiat
                        .contains { fiat in
                            order.fiat == fiat.rawValue
                        }
                }
            } else {
                fiatFiltered = fiatFiltered.filter { $0.fiat == orderFiat.rawValue }
            }
        }
        
        var assetFiltered = fiatFiltered
        if orderAsset != .allAssets {
            if orderAsset == .other {
                assetFiltered = assetFiltered.filter { order in
                    !C2CHistoryResponse.C2COrderAsset
                        .mentionedAssets
                        .contains { asset in
                            order.asset == asset.rawValue
                        }
                }
            } else {
                assetFiltered = assetFiltered.filter { $0.asset == orderAsset.rawValue }
            }
        }
        
        return assetFiltered
    }
    
    // Both types orders sorted and filtered array
    private var c2cOrdersBothTypesFiltered: [C2CHistoryResponse.C2COrderTransformed] {
        let bothtypes = c2cOrdersFiltered + c2cOrdersSecondTypeFiltered
        return bothtypes.sorted {
            $0.createTime > $1.createTime
        }
    }
    
    //MARK: - Initializer
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "binanceColor")!]
        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "binanceColor")!]
        UIRefreshControl.appearance().tintColor = UIColor(named: "binanceColor")
    }
    
    //MARK: - Body
    var body: some View {
        if !loadStatus.isLoading && !loadStatus.isResponseGet {
            showLoadButton(title: "Get Binance P2P Orders")
        } else if loadStatus.isLoading && !loadStatus.isResponseGet {
            ProgressView()
                .tint(Color("binanceColor"))
                .controlSize(.large)
            
        }
        
        if !loadStatus.isLoading && loadStatus.isResponseGet {
            NavigationStack {
                VStack {
                    FilterView(
                        orderType: $orderType,
                        orderStatus: $orderStatus,
                        orderFiat: $orderFiat,
                        orderAsset: $orderAsset,
                        fromDate: $startDate,
                        toDate: $endDate
                    )
                    .onChange(of: orderType) { _ in
                        getBothTypesOrders()
                    }
                    .onChange(of: startDate) { newValue in
                        
                        if let daysDif = Calendar.current.dateComponents([.day], from: newValue, to: endDate).day,
                           daysDif > 30 {
                            endDate = Calendar.current.date(byAdding: .day, value: 30, to: newValue)!
                        }
                        
                        getBothTypesOrders()
                    }
                    .onChange(of: endDate) { newValue in
                        
                        if let daysDif = Calendar.current.dateComponents([.day], from: startDate, to: newValue).day,
                           daysDif > 30 {
                            startDate = Calendar.current.date(byAdding: .day, value: -30, to: newValue)!
                        }
                        
                        getBothTypesOrders()
                    }
                    .onChange(of: orderFiat) { newValue in
                        viewModel.setFiatFilter(for: newValue)
                    }
                    
                    List {
                        ForEach(orderType != .bothTypes ? c2cOrdersFiltered : c2cOrdersBothTypesFiltered) { order in
                            OrderItem(order: order)
                                .background {
                                    NavigationLink("", destination: OrderDetailsView(order: order)).opacity(0)
                                }
                        }
                        
                        CalculatorItem(orders: c2cOrdersFiltered)
                            .onTapGesture {
                                presentCalculatorSheet.toggle()
                            }
                    }
                    .listStyle(.inset)
                    .navigationTitle("P2P Orders")
                    .animation(.default, value: c2cOrdersFiltered)
                    .refreshable {
                        getBothTypesOrders()
                    }
                    .toolbar {
                        Button {
                            if orderFiat != .allFiat && orderFiat != .other {
                                presentCalculatorSheet.toggle()
                            } else {
                                presentCalculatorError.toggle()
                            }
                        } label: {
                            Image(systemName: "gauge.high")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .topTrailing)
                                .foregroundColor(Color("binanceColor"))
                        }
                        .disabled(c2cOrdersSecondTypeFiltered.isEmpty)
                        .opacity(c2cOrdersSecondTypeFiltered.isEmpty ? 0.5 : 1)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                didChangeAPI = false
                                presentAPISheet.toggle()
                            } label: {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30, alignment: .topTrailing)
                                    .foregroundColor(Color("binanceColor"))
                            }
                        }
                    }
                    .sheet(isPresented: $presentCalculatorSheet) {
                        CalculatorView(
                            currentOrderFiat: orderFiat,
                            currentOrderTypeFilter: orderType != .bothTypes ? orderType : .buy,
                            c2cOrders: c2cOrdersFiltered,
                            c2cOrdersSecondType: c2cOrdersSecondTypeFiltered)
                    }
                    .sheet(isPresented: $presentAPISheet) {
                        if didChangeAPI {
                            c2cOrders = []
                            loadStatus = (true, false)
                            getBothTypesOrders()
                        }
                    } content: {
                        NavigationView {
                            BinanceAPIAccountsView(isPresented: $presentAPISheet, didChangeAPI: $didChangeAPI)
                                .environmentObject(viewModel)
                        }
                    }
                    .alert("Choose specific fiat", isPresented: $presentCalculatorError) {
                        Text("Ok")
                            .onTapGesture {
                                presentCalculatorError = false
                            }
                    }
                }
            }
            .tint(Color("binanceColor"))
        }
    }
    
    //MARK: - View Methods
    @ViewBuilder
    private func showLoadButton(title: String) -> some View {
        VStack {
            Button(title) {
                loadButtonPressed()
            }
            .tint(Color("binanceColor"))
            .fontWeight(.bold)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .alert("Error", isPresented: $errorFlag) {
                Text("Ok")
                    .onTapGesture {
                        errorFlag = false
                    }
            } message: {
                Text(responseError?.rawValue ?? "Uknown error")
            }
            .sheet(isPresented: $presentAPISheet) {
                presentAPISheet = false
            } content: {
                NavigationView {
                    BinanceAPIAccountsView(isPresented: $presentAPISheet, didChangeAPI: $didChangeAPI)
                        .environmentObject(viewModel)
                }
            }
            .onAppear {
                if !buttonDidLoad {
                    buttonDidLoad = true
                    loadButtonPressed()
                }
            }
            
            Button("Set Binance P2P API Key") {
                presentAPISheet.toggle()
            }
            .tint(Color("binanceColor"))
            .fontWeight(.bold)
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
    
    //MARK: - Task Methods
    private func loadButtonPressed() {
        if !viewModel.getAccounts().isEmpty {
            loadStatus = (isLoading: true, isResponseGet: false)
            setFiltersToDefault()
            getBothTypesOrders()
        } else {
            presentAPISheet.toggle()
        }
    }
    
    private func getFirstTypeOrders() {
        viewModel.getC2CHistory(
            type: orderType == .bothTypes ? .buy : orderType,
            startTimestamp: startDate,
            endTimestamp: endDate,
            rows: 100
        ) { result in
            switch result {
            case .success(let success):
                withAnimation {
                    loadStatus = (isLoading: false, isResponseGet: true)
                    c2cOrders = success
                }
            case .failure(let failure):
                withAnimation {
                    loadStatus = (isLoading: false, isResponseGet: false)
                    responseError = failure
                    errorFlag.toggle()
                }
            }
        }
    }
    
    private func getSecondTypeOrders() {
        var secondOrderType: C2CHistoryResponse.C2COrderType
        switch orderType {
        case .bothTypes, .buy:
            secondOrderType = .sell
        case .sell:
            secondOrderType = .buy
        }
        
        viewModel.getC2CHistory(
            type: secondOrderType,
            startTimestamp: startDate,
            endTimestamp: endDate,
            rows: 100
        ) { result in
            switch result {
            case .success(let success):
                withAnimation {
                    c2cOrdersSecondType = success
                }
            case .failure:
                break
            }
        }
    }
    
    private func getBothTypesOrders() {
        withAnimation {
            presentCalculatorSheet = false
            c2cOrdersSecondType = []
        }
        getFirstTypeOrders()
        getSecondTypeOrders()
    }
    
    private func setFiltersToDefault() {
        orderType = .bothTypes
        orderStatus = .all
        orderFiat = viewModel.getFiatFilter()
        orderAsset = .allAssets
        startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date.now)!
        endDate = Date.now
    }
}

//MARK: - Preview Struct
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
                .previewDevice("iPhone 14 Pro")
            
            ContentView()
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
                .previewDevice("iPhone SE (3rd generation)")
            
            ContentView()
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
}
