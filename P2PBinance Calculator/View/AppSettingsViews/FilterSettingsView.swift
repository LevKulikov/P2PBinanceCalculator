//
//  FilterSettingsView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 29.09.2023.
//

import SwiftUI

struct FilterSettingsView: View {
    //MARK: - Properties
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var roleFilterSwitch = true
    @State private var dateRangeFilterSwitch = true
    @State private var amountFilterSwitch = true
    private var exampleDateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .month, value: -6, to: Date.now)!.startOfDay
        let max = Date.now
        return min...max
    }
    private var currentDevice: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    //MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .light {
                    Color(uiColor: .systemGray6)
                        .ignoresSafeArea()
                }
                
                List {
                    roleSection
                    dateRangeSection
                    amountSection
                }
                .frame(maxWidth: 900)
                .scrollContentBackground(.hidden)
                .onAppear {
                    onAppearMethod()
                }
            }
            .navigationTitle("Filter settings")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar(currentDevice == .phone ? .hidden : .automatic, for: .tabBar)
        }
    }
    
    //MARK: - View Properties
    private var roleSection: some View {
        Section {
            Toggle("Role filter", isOn: $roleFilterSwitch)
                .tint(SettingsStorage.pickedAppColor)
        } header: {
            VStack(alignment: .leading) {
                Text("Filters by specific advertisment role")
                    .frame(maxWidth: .infinity, alignment: .leading)
                roleFilterExample
            }
        } footer: {
            Text("It is possible to filter Taker, Maker or both roles orders")
        }
        .onChange(of: roleFilterSwitch) { value in
            settingsViewModel.saveRoleFilter(show: value)
        }
    }
    
    private var dateRangeSection: some View {
        Section {
            Toggle("Date range filter", isOn: $dateRangeFilterSwitch)
                .tint(SettingsStorage.pickedAppColor)
        } header: {
            VStack {
                Text("Shows orders from selected date range")
                    .frame(maxWidth: .infinity, alignment: .leading)
                dateRangeFilterExample
            }
        } footer: {
            Text("You can filter up to six months old, and display one month range orders. Also it is possible to filter order in certain time range")
        }
        .onChange(of: dateRangeFilterSwitch) { value in
            settingsViewModel.saveDateRangeFilter(show: value)
        }
    }
    
    private var amountSection: some View {
        Section {
            Toggle("Amount range filter", isOn: $amountFilterSwitch)
                .tint(SettingsStorage.pickedAppColor)
        } header: {
            VStack(alignment: .leading) {
                Text("Filters orders with certain fiat amount range")
                    .frame(maxWidth: .infinity, alignment: .leading)
                amounFilterExample
            }
        } footer: {
            Text("Specific fiat currency must be selected in Fiat filter before use ")
        }
        .onChange(of: amountFilterSwitch) { value in
            settingsViewModel.saveAmounteFilter(show: value)
        }
    }
    
    private var roleFilterExample: some View {
        Picker("Order advertisement role", selection: .constant(C2CHistoryResponse.C2COrderAdvertisementRole.maker)) {
            ForEach(C2CHistoryResponse.C2COrderAdvertisementRole.allCases, id: \.hashValue) {
                Text($0.rawValue)
                    .tag($0)
            }
        }
        .buttonStyle(.bordered)
        .tint(SettingsStorage.pickedAppColor)
    }
    
    private var dateRangeFilterExample: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                DatePicker("From date", selection: .constant(Date.now.dayBefore), in: exampleDateRange, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .applyTextColor(SettingsStorage.pickedAppColor)
                
                Image(systemName: "arrowshape.right.fill")
                    .foregroundColor(SettingsStorage.pickedAppColor)
                    .imageScale(.large)
                
                DatePicker("To date", selection: .constant(Date.now), in: exampleDateRange, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .applyTextColor(SettingsStorage.pickedAppColor)
            }
        }
    }
    
    private var amounFilterExample: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                TextField("From USD amount", text: .constant(""))
                    .frame(minWidth: 80, maxWidth: 150)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                
                Image(systemName: "arrowshape.right.fill")
                    .foregroundColor(SettingsStorage.pickedAppColor)
                    .imageScale(.large)
                
                TextField("To USD amount", text: .constant(""))
                    .frame(minWidth: 80, maxWidth: 150)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
            }
            .allowsHitTesting(false)
        }
    }
    
    //MARK: - Mthods
    private func onAppearMethod() {
        roleFilterSwitch = settingsViewModel.publishedRoleFilterShow
        dateRangeFilterSwitch = settingsViewModel.publishedDateRangeFilterShow
        amountFilterSwitch = settingsViewModel.publishedAmountFilterShow
    }
}

#Preview {
//    NavigationStack {
        FilterSettingsView()
            .environmentObject(SettingsViewModel(
                settingsStorage: SettingsStorageMock(),
                dataStorage: DataStorageMock()
            ))
//    }
}
