//
//  ContentView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import SwiftUI
import Foundation

struct P2POrdersView: View {
    //MARK: - Properties
    //MARK: Environment and state props
    @EnvironmentObject var viewModel: GeneralViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var buttonDidLoad = false
    @State private var loadStatus = (isLoading: false, isResponseGet: false)
    /// Needed when first load is done, so large ProgressView will not appear
    @State private var modalLaoding = false
    @State private var responseError: ExchangeConnection.ExchangeError? = nil
    @State private var errorFlag = false
    @State private var presentStatisticsSheet = false
    @State private var presentAPISheet = false
    @State private var presentStatisticsError = false
    @State private var didChangeAPI = false
    @State private var c2cOrders: [C2CHistoryResponse.C2COrderTransformed] = []
    /// If c2cOrders is buy, c2cOrdersSecondType is sell, and vise versa
    @State private var c2cOrdersSecondType: [C2CHistoryResponse.C2COrderTransformed] = []
    @State private var selectedOrder: C2CHistoryResponse.C2COrderTransformed?
    
    //MARK: Filtering props
    @State private var orderType: C2CHistoryResponse.C2COrderType = .bothTypes
    @State private var orderStatus: C2CHistoryResponse.C2COrderStatus = .all
    @State private var orderFiat: C2CHistoryResponse.C2COrderFiat = .allFiat
    @State private var orderAsset: C2CHistoryResponse.C2COrderAsset = .allAssets
    @State private var customFiat = ""
    @State private var customAsset = ""
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date.now)!.startOfDay
    @State private var endDate = Date.now.endOfDay
    @State private var fromFiatValue = ""
    @State private var toFiatValue = ""
    @State private var orderAdvertisementRole: C2CHistoryResponse.C2COrderAdvertisementRole = .bothRoles
    
    //MARK: Computed props
    // Filters c2cOrders according to filter settings
    private var c2cOrdersFiltered: [C2CHistoryResponse.C2COrderTransformed] {
        filterOrders(c2cOrders)
    }
    
    // Filters c2cOrdersSecond according to filter settings
    private var c2cOrdersSecondTypeFiltered: [C2CHistoryResponse.C2COrderTransformed] {
        filterOrders(c2cOrdersSecondType)
    }
    
    // Both types orders sorted and filtered array
    private var c2cOrdersBothTypesFiltered: [C2CHistoryResponse.C2COrderTransformed] {
        let bothtypes = c2cOrdersFiltered + c2cOrdersSecondTypeFiltered
        return bothtypes.sorted {
            $0.createTime > $1.createTime
        }
    }
    
    /// Shortcut to get current user device, it is just for convenience
    private var currentDeviceType: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    //MARK: - Body
    var body: some View {
        if !loadStatus.isLoading && !loadStatus.isResponseGet {
            showLoadButton(title: "Get P2P Orders")
        } else if !modalLaoding && loadStatus.isLoading && !loadStatus.isResponseGet {
            ProgressView()
                .tint(SettingsStorage.pickedAppColor)
                .controlSize(.large)
        }
        
        if modalLaoding || (!loadStatus.isLoading && loadStatus.isResponseGet) {
            NavigationSplitView() {
                VStack {
                    // Because of error of iOS 16+, toolbar for pads is not set, buttons are moved to VStack above filterView
                    if currentDeviceType == .pad {
                        ipadAccountAndStatisticsButtonsView
                    }
                    
                    filterView
                    
                    listView
                        .listStyle(.inset)
                        .animation(.default, value: c2cOrdersFiltered)
                        .refreshable {
                            getBothTypesOrders()
                        }
                        .scrollDismissesKeyboard(.immediately)
                        .toolbar {
                            // Because of error of iOS 16+, toolbar for pads is not set, buttons are moved to VStack above filterView
                            if [UIUserInterfaceIdiom.mac, UIUserInterfaceIdiom.phone].contains(currentDeviceType) {
                                navigationBar
                            }
                        }
                        .sheet(isPresented: $presentAPISheet) {
                            if didChangeAPI {
                                getBothTypesOrders()
                            }
                        } content: {
                            BinanceAPIAccountsView(isPresented: $presentAPISheet, didChangeAPI: $didChangeAPI)
                        }
                        .alert("Choose specific fiat", isPresented: $presentStatisticsError) {
                            ForEach(C2CHistoryResponse.C2COrderFiat.mentionedFiat, id: \.self) { fiat in
                                Button(fiat.rawValue) {
                                    orderFiat = fiat
                                    presentStatisticsSheet.toggle()
                                }
                            }
                            
                            Button("Cancel", role: .cancel) {
                                presentStatisticsError = false
                            }
                        }
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
                        .onChange(of: customFiat) { newValue in
                            viewModel.setCustomFiatFilter(for: newValue)
                        }
                } //: VStack end
                .frame(minWidth: 300)
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle("P2P Orders")
                .navigationSplitViewColumnWidth(min: 300, ideal: 600, max: 1000)
            } detail: {
                if let selectedOrder {
                    OrderDetailsView(order: selectedOrder)
                } else {
                    NoSelectedOrderView()
                }
            } //: NavigationStack end
            .navigationSplitViewStyle(.balanced)
            .navigationSplitViewColumnWidth(800)
            .tint(SettingsStorage.pickedAppColor)
            .onAppear {
                listOnAppearTask()
            }
        }
    }
    
    private var filterView: some View {
        FilterView(
            orderType: $orderType,
            orderStatus: $orderStatus,
            orderFiat: $orderFiat,
            orderAsset: $orderAsset,
            customFiat: $customFiat,
            customAsset: $customAsset,
            fromDate: $startDate,
            toDate: $endDate,
            fromFiatValue: $fromFiatValue,
            toFiatValue: $toFiatValue,
            orderAdvertisementRole: $orderAdvertisementRole
        )
    }
    
    private var statisticsView: some View {
        StatisticsView(
            currentOrderFiat: orderFiat,
            currentCustomFiat: customFiat,
            currentOrderTypeFilter: orderType != .bothTypes ? orderType : .buy,
            startDate: startDate,
            endDate: endDate,
            c2cOrders: c2cOrdersFiltered,
            c2cOrdersSecondType: c2cOrdersSecondTypeFiltered)
    }
    
    private var listView: some View {
        List(selection: $selectedOrder) {
            ForEach(orderType != .bothTypes ? c2cOrdersFiltered : c2cOrdersBothTypesFiltered) { order in
                getOrderRow(for: order)
            }
                                    
            CalculatorItem(orders: orderType != .bothTypes ? c2cOrdersFiltered : c2cOrdersBothTypesFiltered)
                .listRowSeparatorTint(SettingsStorage.pickedAppColor, edges: .top)
                .listRowBackground(SettingsStorage.pickedAppColor.opacity(0.1))
        }
        .tint(Color(uiColor: .secondarySystemFill))
        .navigationDestination(for: C2CHistoryResponse.C2COrderTransformed.self) { order in
            OrderDetailsView(order: order)
        }
    }
    
    /// Because of iOS16+ error of displaying sidebar toolbar content, if is needed to use this view in navigation content view to display buttons
    private var ipadAccountAndStatisticsButtonsView: some View {
        HStack {
            accountViewShowButton
                .scaleEffect(1.2, anchor: .leading)
            Spacer()
            statisticsShowButton
                .scaleEffect(1.2, anchor: .trailing)
        }
        .padding(.horizontal)
        .padding(.vertical, 1.5)
    }
    
    @ToolbarContentBuilder
    private var navigationBar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            accountViewShowButton
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            statisticsShowButton
        }
    }
    
    private var statisticsShowButton: some View {
        Button {
            statisticsShowButtonPressed()
        } label: {
            if !loadStatus.isLoading {
                Image(systemName: "gauge.high")
                    .font(.custom("title1.5", size: 25))
                    .foregroundColor(SettingsStorage.pickedAppColor)
            } else {
                ProgressView()
                    .tint(SettingsStorage.pickedAppColor)
                    .controlSize(.large)
                    .scaleEffect(currentDeviceType == .pad ? 0.65 : 1)
            }
        }
        .opacity(c2cOrdersSecondTypeFiltered.isEmpty ? 0.5 : 1)
        .contentShape([.hoverEffect, .contextMenuPreview], Circle())
        .hoverEffect(.highlight)
        .disabled(c2cOrdersSecondTypeFiltered.isEmpty)
        .contextMenu {
            Button {
                statisticsShowButtonPressed()
            } label: {
                Label("Show statistics", systemImage: "gauge.high")
            }
        } preview: {
            if orderFiat != .allFiat, orderFiat != .other {
                statisticsView
            } else {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .foregroundStyle(.secondary)
                    
                    Text("Please, select certain __Fiat__ in filter before open Statistics")
                        .font(.title2)
                        .frame(width: 250)
                        .multilineTextAlignment(.leading)
                }
                .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                .padding()
            }
        }
        .sheet(isPresented: $presentStatisticsSheet) {
            statisticsView
        }
    }
    
    private var accountViewShowButton: some View {
        Menu {
            ForEach(viewModel.getAccounts()) { account in
                Button(account.name) {
                    viewModel.selectedAccount = nil
                    viewModel.selectedAccount = account
                    getBothTypesOrders()
                }
            }
        } label: {
            HStack {
                Image(systemName: "person.circle")
                    .font(.custom("title1.5", size: 25))
                    .foregroundColor(SettingsStorage.pickedAppColor)
                
                Text(viewModel.selectedAccount?.name ?? "")
                    .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .phone ? 180 : 120, alignment: .leading)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
            }
        } primaryAction: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                didChangeAPI = false
                presentAPISheet.toggle()
            }
        }
        .hoverEffect(.highlight)
    }
    
    //MARK: - View Methods
    @ViewBuilder
    private func showLoadButton(title: String) -> some View {
        VStack {
            Button(title) {
                loadButtonPressed()
            }
            .tint(SettingsStorage.pickedAppColor)
            .fontWeight(.bold)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .alert("Error", isPresented: $errorFlag) {
                Button("Ok") {
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
                loadButtonOnAppearTask()
            }
            
            Button("Set P2P API Key") {
                presentAPISheet.toggle()
            }
            .tint(SettingsStorage.pickedAppColor)
            .fontWeight(.bold)
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
    
    @ViewBuilder
    private func getOrderRow(for order: C2CHistoryResponse.C2COrderTransformed) -> some View {
        OrderItem(order: order)
            .background {
                NavigationLink(value: order) {
                    Text("")
                }.opacity(0)
            }
            .swipeActions(edge: .leading) {
                Button {
                    setOrderInArray(order: order, count: !order.activeForCount)
                } label: {
                    Label(order.activeForCount ? "Do not count" : "Count", systemImage: order.activeForCount ? "multiply" : "checkmark.circle")
                }
                .tint(order.activeForCount ? .red : .green)
            }
    }
    
    //MARK: - Task Methods
    private func loadButtonOnAppearTask() {
        modalLaoding = false
        if !buttonDidLoad {
            buttonDidLoad = true
            loadButtonPressed()
        }
    }
    
    private func listOnAppearTask() {
        modalLaoding = true
    }
    
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
            presentStatisticsSheet = false
            selectedOrder = nil
            loadStatus = (isLoading: true, isResponseGet: false)
            c2cOrders = []
            c2cOrdersSecondType = []
        }
        getFirstTypeOrders()
        getSecondTypeOrders()
    }
    
    private func setFiltersToDefault() {
        orderType = .bothTypes
        orderStatus = .all
        orderFiat = viewModel.getFiatFilter()
        customFiat = viewModel.getCustomFiatFilter()
        orderAsset = .allAssets
        startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date.now)!.startOfDay
        endDate = Date.now.endOfDay
        fromFiatValue = ""
        toFiatValue = ""
        orderAdvertisementRole = .bothRoles
    }
    
    private func statisticsShowButtonPressed() {
        if orderFiat != .allFiat, orderFiat != .other {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                presentStatisticsSheet.toggle()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                presentStatisticsError.toggle()
            }
        }
    }
    
    private func setOrderInArray(order: C2CHistoryResponse.C2COrderTransformed, count: Bool) {
        var orderCountSet = order
        orderCountSet.activeForCount = count
        if let orderIndex = c2cOrders.firstIndex(of: order) {
            c2cOrders.remove(at: orderIndex)
            c2cOrders.insert(orderCountSet, at: orderIndex)
        } else if let orderIndex = c2cOrdersSecondType.firstIndex(of: order) {
            c2cOrdersSecondType.remove(at: orderIndex)
            c2cOrdersSecondType.insert(orderCountSet, at: orderIndex)
        }
    }
    
    private func filterOrders(_ orders: [C2CHistoryResponse.C2COrderTransformed]) -> [C2CHistoryResponse.C2COrderTransformed] {
        var statusFiltered = orders
        if orderStatus != .all {
            statusFiltered = statusFiltered.filter { $0.orderStatus == orderStatus }
        }
        
        var fiatFiltered = statusFiltered
        if orderFiat != .allFiat {
            switch orderFiat {
            case .other:
                fiatFiltered = fiatFiltered.filter { order in
                    !C2CHistoryResponse.C2COrderFiat
                        .mentionedFiat
                        .contains { fiat in
                            order.fiat == fiat.rawValue
                        }
                }
            case .custom:
                fiatFiltered = fiatFiltered.filter { $0.fiat == customFiat }
            default:
                fiatFiltered = fiatFiltered.filter { $0.fiat == orderFiat.rawValue }
            }
        }
        
        var assetFiltered = fiatFiltered
        if orderAsset != .allAssets {
            switch orderAsset {
            case .other:
                assetFiltered = assetFiltered.filter { order in
                    !C2CHistoryResponse.C2COrderAsset
                        .mentionedAssets
                        .contains { asset in
                            order.asset == asset.rawValue
                        }
                }
            case .custom:
                assetFiltered = assetFiltered.filter { $0.asset == customAsset }
            default:
                assetFiltered = assetFiltered.filter { $0.asset == orderAsset.rawValue }
            }
        }
        
        var fromToFiatValueFiltered = assetFiltered
        if orderFiat != .allFiat {
            if !fromFiatValue.isEmpty, let fromFiatAmount = Float(fromFiatValue) {
                fromToFiatValueFiltered = fromToFiatValueFiltered.filter { $0.totalPrice >= fromFiatAmount }
            }
            
            if !toFiatValue.isEmpty, let toFiatAmount = Float(toFiatValue) {
                fromToFiatValueFiltered = fromToFiatValueFiltered.filter { $0.totalPrice <= toFiatAmount }
            }
        }
        
        var advRoleFiltered = fromToFiatValueFiltered
        if orderAdvertisementRole != .bothRoles {
            advRoleFiltered = advRoleFiltered.filter { $0.advertisementRole == orderAdvertisementRole }
        }
        
        return advRoleFiltered
    }
}

//MARK: - Preview Struct
struct P2POrdersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            P2POrdersView()
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
                .environmentObject(SettingsViewModel(
                    settingsStorage: SettingsStorageMock(),
                    dataStorage: DataStorageMock()
                ))
                .previewDevice("iPhone 15 Pro")
            
            P2POrdersView()
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
                .previewDevice("iPhone SE (3rd generation)")
                .environmentObject(SettingsViewModel(
                    settingsStorage: SettingsStorageMock(),
                    dataStorage: DataStorageMock()
                ))
            
            P2POrdersView()
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .environmentObject(SettingsViewModel(
                    settingsStorage: SettingsStorageMock(),
                    dataStorage: DataStorageMock()
                ))
        }
    }
}
