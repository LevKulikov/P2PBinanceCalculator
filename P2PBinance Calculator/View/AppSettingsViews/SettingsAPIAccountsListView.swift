//
//  SettingsAPIAccountsListView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 29.09.2023.
//

import SwiftUI

struct SettingsAPIAccountsListView: View {
    //MARK: - Properties
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var accounts: [APIAccount] = []
    @State private var maxAccountLimitReached = false
    @State private var accountAction: SettingsSingleAPIAccountView.AccountAction?
    @State private var presentAccountSheet = false
    @State private var didChangeApi = false
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
                    ForEach(accounts) { account in
                        getAccountRowFor(account)
                    }
                    .onDelete(perform: deleteAccounts)
                    .onMove(perform: reorderAccounts)
                    
                    if settingsViewModel.getAccounts().isEmpty {
                        noAccountsRow
                    }
                }
                .frame(maxWidth: 900)
                .scrollContentBackground(.hidden)
                .onAppear {
                    onAppearMethod()
                }
                .alert("Maximum accounts number is 5", isPresented: $maxAccountLimitReached) {
                    Button("Ok") {}
                }
            }
            .navigationTitle("Binance accounts")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationDestination(for: SettingsSingleAPIAccountView.AccountAction.self) { action in
                SettingsSingleAPIAccountView(action: action, didChangeApi: $didChangeApi)
            }
            .toolbar(currentDevice == .phone ? .hidden : .automatic, for: .tabBar)
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    EditButton()
                        .foregroundStyle(SettingsStorage.pickedAppColor)
                
                    Spacer()
                
                    if settingsViewModel.ableToAddAccount {
                        createAccountButton
                    } else {
                        maxAccountLimitButton
                    }
                }
            }
        }
    }
    
    //MARK: - View properties
    private var noAccountsRow: some View {
        Text("Tap to create")
            .font(.title3)
            .foregroundColor(SettingsStorage.pickedAppColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                accountAction = .create
                presentAccountSheet.toggle()
            }
    }
    
    private var createAccountButton: some View {
        NavigationLink (value: SettingsSingleAPIAccountView.AccountAction.create) {
            Image(systemName: "plus")
                .foregroundColor(SettingsStorage.pickedAppColor)
        }

    }
    
    private var maxAccountLimitButton: some View {
        Button {
            maxAccountLimitReached.toggle()
        } label: {
            Image(systemName: "nosign")
                .foregroundColor(SettingsStorage.pickedAppColor)
        }
    }
    
    //MARK: - View methods
    @ViewBuilder
    func getAccountRowFor(_ account: APIAccount) -> some View {
        NavigationLink(value: SettingsSingleAPIAccountView.AccountAction.update(account)) {
            Text(account.name)
                .font(.title3)
        }
    }
    
    //MARK: - Methods
    private func onAppearMethod() {
        withAnimation {
            didChangeApi = false
            accounts = settingsViewModel.getAccounts()
        }
    }
    
    private func deleteAccounts(indexes: IndexSet) {
        for index in indexes {
            accounts.remove(at: index)
            settingsViewModel.deleteAccount(at: index, completionHandler: nil)
        }
    }
    
    private func reorderAccounts(fromOffsets: IndexSet, toOffset: Int) {
        accounts.move(fromOffsets: fromOffsets, toOffset: toOffset)
        settingsViewModel.moveAccounts(fromOffsets: fromOffsets, toOffset: toOffset, completionHandler: nil)
    }
}

#Preview {
//    NavigationStack {
        SettingsAPIAccountsListView()
            .environmentObject(SettingsViewModel(
                settingsStorage: SettingsStorageMock(),
                dataStorage: DataStorageMock()
            ))
//    }
}
