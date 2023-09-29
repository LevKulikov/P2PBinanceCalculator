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
    @State private var accountAction: SettingsSingleAPIAccountView.AccountAction = .create
    @State private var presentAccountSheet = false
    @State private var didChangeApi = false
    private var currentDevice: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    //MARK: - Body
    var body: some View {
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
            .sheet(isPresented: $presentAccountSheet) {
                withAnimation {
                    didChangeApi = false
                    accounts = settingsViewModel.getAccounts()
                }
            } content: {
                NavigationStack {
                    SettingsSingleAPIAccountView(action: $accountAction, didChangeApi: $didChangeApi)
                }
            }
            .alert("Maximum accounts number is 5", isPresented: $maxAccountLimitReached) {
                Button("Ok") {}
            }
        }
        .navigationTitle("Binance accounts")
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
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
        .toolbar(currentDevice == .phone ? .hidden : .automatic, for: .tabBar)
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
        Button() {
            accountAction = .create
            presentAccountSheet.toggle()
        } label: {
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
        Text(account.name)
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                accountAction = .update(account)
                presentAccountSheet.toggle()
            }
    }
    
    //MARK: - Methods
    private func onAppearMethod() {
        accounts = settingsViewModel.getAccounts()
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
    NavigationStack {
        SettingsAPIAccountsListView()
            .environmentObject(SettingsViewModel(
                settingsStorage: SettingsStorageMock(),
                dataStorage: DataStorageMock()
            ))
    }
}
