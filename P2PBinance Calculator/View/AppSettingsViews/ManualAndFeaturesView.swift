//
//  ManualAndFeaturesView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 03.10.2023.
//

import SwiftUI

struct ManualAndFeaturesView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "gearshape.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(SettingsStorage.pickedAppColor)
                
                Text("In development")
                    .font(.largeTitle)
                
                Text("Comming soon")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Manual and features")
            .offset(y: -50)
        }
    }
}

#Preview {
    ManualAndFeaturesView()
}
