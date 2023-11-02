//
//  ChartPicker.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 20.08.2023.
//

import SwiftUI

struct AssetPicker: View {
    let assets: [String]
    @Binding var pickerSelection: String
    
    var body: some View {
        Picker("Assets picker to display in the chart", selection: $pickerSelection) {
            ForEach(assets) { asset in
                Text(asset)
                    .tag(asset)
            }
        }
        .pickerStyle(.segmented)
    }
}

extension String: Identifiable {
    public var id: Int {
        self.hashValue
    }
}

struct AssetPicker_Previews: PreviewProvider {
    static var previews: some View {
        AssetPicker(assets: ["USDT", "BTC", "BNB"], pickerSelection: .constant("USDT"))
    }
}
