//
//  ManualModel.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 04.10.2023.
//

import Foundation

struct ManualModel: Identifiable, Hashable {
    let id = UUID()
    
    /// Image name to show like in the list
    let subImageName: String
    /// Short representation of manual
    let shortTitle: String
    /// Name of Image of iPhone to display in the main view
    let mainPhoneImageName: String
    /// Name of Image of iPad  to display in the main view
    let mainPadImageName: String
    /// Title under Image for the next description text
    let textTitle: String
    /// Main manual description
    let mainDescriptionText: String
}
