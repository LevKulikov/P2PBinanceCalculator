//
//  ManualStorage.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 04.10.2023.
//

import Foundation

protocol ManualStorageProtocol: AnyObject {
    var manuals: [ManualModel] { get }
}

final class ManualStorage: ManualStorageProtocol {
    var manuals: [ManualModel] {
        return allManuals
    }
    
    private let allManuals: [ManualModel] = [
        ManualModel(
            subImageName: "chart.bar.xaxis",
            shortTitle: "Orders statistics",
            mainPhoneImageName: "statisticsPhone",
            mainPadImageName: "statisticsPad",
            textTitle: "Orders Statistics",
            mainDescriptionText: "You can open statistics of all filtered orders, and get such values as Total Value, Profit and Medium spread. Also here is located Line Chart with buy and sell prices. You can selected which asset price should be shown in the Line chart"
        ),
        ManualModel(
            subImageName: "list.number",
            shortTitle: "Statistics values details",
            mainPhoneImageName: "statisticsPhone",
            mainPadImageName: "statisticsPad",
            textTitle: "Statistics values details",
            mainDescriptionText: "Hold values - get more information"
        ),
        ManualModel(
            subImageName: "line.3.horizontal.decrease.circle",
            shortTitle: "Order filters",
            mainPhoneImageName: "statisticsPhone",
            mainPadImageName: "statisticsPad",
            textTitle: "Order Filters",
            mainDescriptionText: "Filter orders by your preferences"
        )
    ]
}
