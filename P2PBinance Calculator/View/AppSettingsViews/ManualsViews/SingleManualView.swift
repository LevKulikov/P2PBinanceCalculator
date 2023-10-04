//
//  SingleManualView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 04.10.2023.
//

import SwiftUI

struct SingleManualView: View {
    //MARK: - Properties
    let manual: ManualModel
    private var currentDevice: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    //MARK: - Body
    var body: some View {
        ScrollView {
            VStack {
                Image(currentDevice == .phone ? manual.mainPhoneImageName : manual.mainPadImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: currentDevice == .phone ? 550 : 650)
                
                Group {
                    Text(manual.textTitle)
                        .font(.title)
                        .bold()
                    Text(manual.mainDescriptionText)
                        .padding(.bottom, 30)
                }
                .frame(maxWidth: 900, alignment: .leading)
            }
            .padding()
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
    
    //MARK: - Methods
}

#Preview {
    SingleManualView(
        manual:
            ManualModel(
                subImageName: "chart.bar.xaxis",
                shortTitle: "Orders statistics",
                mainPhoneImageName: "statisticsPhone",
                mainPadImageName: "statisticsPad",
                textTitle: "Orders Statistics",
                mainDescriptionText: "You can open statistics of all filtered orders, and get such values as Total Value, Profit and Medium spread. Also here is located Line Chart with buy and sell prices. You can selected which asset price should be shown in the Line chart"
            )
    )
}
