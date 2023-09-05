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
    @State private var accounts: [APIAccount] = []
    
    var body: some View {
        VStack {
            List {
                ForEach(accounts) { account in
                    NavigationLink {
                        BinanceAccountView(action: .update(account), isPresented: $isPresented, didChangeAPI: $didChangeAPI)
                            .environmentObject(viewModel)
                    } label: {
                        Text(account.name)
                            .font(.title3)
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
        }
        .navigationTitle("Binance accounts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundColor(Color("binanceColor"))
            }
        }
        .toolbar {
            NavigationLink {
                BinanceAccountView(action: .create, isPresented: $isPresented, didChangeAPI: $didChangeAPI)
                    .environmentObject(viewModel)
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(Color("binanceColor"))
            }
        }
        .onAppear {
            accounts = viewModel.getAccounts()
        }
    }
}

struct BinanceAPIAccountsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BinanceAPIAccountsView(isPresented: .constant(true), didChangeAPI: .constant(true))
                .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
        }
    }
}
