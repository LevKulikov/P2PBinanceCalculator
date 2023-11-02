//
//  ManualAndFeaturesView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 03.10.2023.
//

import SwiftUI

struct ManualAndFeaturesListView: View {
    //MARK: - Properties
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.colorScheme) var colorScheme
    
    //MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .light {
                    Color(uiColor: .systemGray6)
                        .ignoresSafeArea()
                }
                
                List() {
                    ForEach(settingsViewModel.manualStorage.manuals) { manual in
                        getManualRow(for: manual)
                    }
                }
                .frame(maxWidth: 900)
                .scrollContentBackground(.hidden)
                .navigationTitle("Manual and features")
                .navigationDestination(for: ManualModel.self) { manual in
                    ManualsPagingView(manualStorage: settingsViewModel.manualStorage, selectedManual: manual)
                }
            }
        }
    }
    
    //MARK: - View properties
    
    //MARK: - ViewBuilder mehtods
    @ViewBuilder
    private func getManualRow(for manual: ManualModel) -> some View {
        NavigationLink(value: manual) {
            Label() {
                Text(manual.shortTitle)
            } icon: {
                Image(systemName: manual.subImageName)
                    .foregroundStyle(SettingsStorage.pickedAppColor)
            }
        }
    }
    
    //MARK: - Methods
    
}

#Preview {
    ManualAndFeaturesListView()
        .environmentObject(SettingsViewModel(
            settingsStorage: SettingsStorageMock(),
            dataStorage: DataStorageMock()
        ))
}
