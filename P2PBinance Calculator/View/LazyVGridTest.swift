//
//  LazyVGridTest.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 04.09.2023.
//

import SwiftUI

struct LazyVGridTest: View {
    @EnvironmentObject var viewModel: GeneralViewModel
    @State private var c2cOrders: [C2CHistoryResponse.C2COrderTransformed] = []
    @State private var textField = ""
    
    var body: some View {
        List{
            Section {
                ForEach(c2cOrders) { order in
                    OrderItem(order: order)
                }
            } header: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search", text: $textField)
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            getFirstTypeOrders()
        }
    }
    
    private func getFirstTypeOrders() {
        viewModel.getC2CHistory(
            type: .buy,
            startTimestamp: Date.now.dayBefore,
            endTimestamp: Date.now,
            rows: 100
        ) { result in
            switch result {
            case .success(let success):
                withAnimation {
                    c2cOrders = success
                }
            case .failure:
                break
            }
        }
    }
}

struct LazyVGridTest_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGridTest()
            .environmentObject(GeneralViewModelMock(dataStorage: DataStorageMock()) as GeneralViewModel)
    }
}
