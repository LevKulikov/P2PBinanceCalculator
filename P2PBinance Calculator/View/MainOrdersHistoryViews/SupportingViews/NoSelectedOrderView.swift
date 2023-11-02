//
//  NoSelectedOrderView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 21.09.2023.
//

import SwiftUI

struct NoSelectedOrderView: View {
    @Environment(\.dismiss) var dismiss
    /// Do not touch it
    
    var body: some View {
        VStack {
            Image(systemName: "list.bullet.rectangle.portrait")
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                .foregroundStyle(SettingsStorage.pickedAppColor)
            Text("Order is not selected")
                .font(.largeTitle)
            Text("Please, select any order in left-hand menu")
                .font(.headline)
                .foregroundStyle(Color.secondary)
        }
        .onTapGesture {
            dismiss()
        }
    }
}

#Preview {
    NoSelectedOrderView()
}
