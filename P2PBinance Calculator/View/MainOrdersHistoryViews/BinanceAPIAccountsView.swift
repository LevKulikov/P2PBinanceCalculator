//
//  BinanceAPIAccountsView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 18.08.2023.
//

import SwiftUI

struct BinanceAPIAccountsView: View {
    @EnvironmentObject var viewModel: GeneralViewModel
    @Binding var isPresented: Bool
    @Binding var didChangeAPI: Bool
    @State private var editMode: EditMode = .inactive
    @State private var accounts: [APIAccount] = []
    @State private var navigationPath = NavigationPath()
    @State private var selectedAccount: APIAccount?
    @State private var maxAccountLimitReached = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(accounts) { account in
                    createAccountRow(for: account)
                }
                .onDelete(perform: deleteAccounts)
                .onMove(perform: reorderAccounts)
                
                if viewModel.getAccounts().isEmpty {
                    noAccountsRow
                }
            }
            .listRowBackground(Color.clear)
            .navigationTitle("Binance accounts")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Maximum accounts number is 5", isPresented: $maxAccountLimitReached) {
                Button("Ok") {}
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    editListButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.ableToAddAccount {
                        createAccountButton
                    } else {
                        maxAccountLimitButton
                    }
                }
            }
            .onAppear {
                accounts = viewModel.getAccounts()
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    private var noAccountsRow: some View {
        NavigationLink {
            BinanceAccountView(action: .create, isPresented: $isPresented, didChangeAPI: $didChangeAPI)
                .environmentObject(viewModel)
        } label: {
            Text("No accounts added")
                .font(.title2)
                .foregroundColor(SettingsStorage.pickedAppColor)
        }
    }
    
    private var editListButton: some View {
        EditButton()
            .foregroundColor(SettingsStorage.pickedAppColor)
            .navigationDestination(for: APIAccount.self) { account in
                BinanceAccountView(action: .update(account), isPresented: $isPresented, didChangeAPI: $didChangeAPI)
                    .environmentObject(viewModel)
            } // NavigationDestination is here because if it is located with List, EditButton stops working
    }
    
    private var createAccountButton: some View {
        NavigationLink {
            BinanceAccountView(action: .create, isPresented: $isPresented, didChangeAPI: $didChangeAPI)
                .environmentObject(viewModel)
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
    
    @ViewBuilder
    private func createAccountRow(for account: APIAccount) -> some View {
        HStack {
            Text(account.name)
                .font(.title3)
            
            Spacer()
            
            if editMode == .inactive {
                Button {
                    navigationPath.append(account)
                } label: {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(SettingsStorage.pickedAppColor)
                        .font(.title3)
                }
                .buttonStyle(.borderless)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if editMode == .inactive {
                viewModel.selectedAccount = account
                selectedAccount = account
                isPresented.toggle()
                didChangeAPI = true
            }
        }
        .contextMenu {
            Button {
                viewModel.selectedAccount = account
                isPresented.toggle()
                didChangeAPI = true
            } label: {
                Label("Select", systemImage: "checkmark.circle")
            }
            
            Button {
                navigationPath.append(account)
            } label: {
                Label("Edit", systemImage: "square.and.pencil")
            }
        }
        .listRowBackground(selectedAccount == account ? Color(uiColor: UIColor.quaternaryLabel) : nil)
    }
    
    private func deleteAccounts(indexes: IndexSet) {
        for index in indexes {
            accounts.remove(at: index)
            viewModel.deleteAccount(at: index, completionHandler: nil)
        }
        viewModel.selectedAccount = viewModel.getAccounts().first
        didChangeAPI = true
    }
    
    private func reorderAccounts(fromOffsets: IndexSet, toOffset: Int) {
        accounts.move(fromOffsets: fromOffsets, toOffset: toOffset)
        viewModel.moveAccounts(fromOffsets: fromOffsets, toOffset: toOffset)
        didChangeAPI = true
    }
}

struct BinanceAPIAccountsView_Previews: PreviewProvider {
    static var previews: some View {
            BinanceAPIAccountsView(isPresented: .constant(true), didChangeAPI: .constant(true))
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
    }
}
