//
//  ManualsPagingView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 04.10.2023.
//

import SwiftUI

struct ManualsPagingView: View {
    let manualStorage: ManualStorageProtocol
    @State var selectedManual: ManualModel
    
    var body: some View {
        TabView(selection: $selectedManual) {
            ForEach(manualStorage.manuals) { manual in
                SingleManualView(manual: manual)
                    .tag(manual)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .padding(.bottom, 15)
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let manualStorage = ManualStorage()
    
    return ManualsPagingView(
        manualStorage: manualStorage,
        selectedManual: manualStorage.manuals.last!
    )
}
