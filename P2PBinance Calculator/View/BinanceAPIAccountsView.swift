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
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ForEach(accounts) { account in
                    createAccountRow(for: account)
                }
                .onDelete { indexes in
                    for index in indexes {
                        accounts.remove(at: index)
                        viewModel.deleteAccount(at: index, completionHandler: nil)
                    }
                    viewModel.selectedAccount = viewModel.getAccounts().first
                    didChangeAPI = true
                }
                .onMove { fromOffsets, toOffset in
                    accounts.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    viewModel.moveAccounts(fromOffsets: fromOffsets, toOffset: toOffset)
                    didChangeAPI = true
                }
                
                if viewModel.getAccounts().isEmpty {
                    NavigationLink {
                        BinanceAccountView(action: .create, isPresented: $isPresented, didChangeAPI: $didChangeAPI)
                            .environmentObject(viewModel)
                    } label: {
                        Text("No accounts added")
                            .font(.title2)
                            .foregroundColor(Color("binanceColor"))
                    }
                }
            }
            .listRowBackground(Color.clear)
            .navigationTitle("Binance accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .foregroundColor(Color("binanceColor"))
                        .navigationDestination(for: APIAccount.self) { account in
                            BinanceAccountView(action: .update(account), isPresented: $isPresented, didChangeAPI: $didChangeAPI)
                                .environmentObject(viewModel)
                        } // NavigationDestination is here because if it is located with List, EditButton stops working
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        BinanceAccountView(action: .create, isPresented: $isPresented, didChangeAPI: $didChangeAPI)
                            .environmentObject(viewModel)
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color("binanceColor"))
                    }
                }
            }
            .onAppear {
                accounts = viewModel.getAccounts()
            }
            .environment(\.editMode, $editMode)
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
                        .foregroundColor(Color("binanceColor"))
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
        }
        .listRowBackground(selectedAccount == account ? Color(uiColor: UIColor.quaternaryLabel) : nil)
    }
}

struct BinanceAPIAccountsView_Previews: PreviewProvider {
    static var previews: some View {
//        NavigationView {
            BinanceAPIAccountsView(isPresented: .constant(true), didChangeAPI: .constant(true))
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
//        }
    }
}
