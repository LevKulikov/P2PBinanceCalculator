//
//  ColorModeView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 01.10.2023.
//

import SwiftUI

struct ColorModeView: View {
    //MARK: - Properties
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var systemScheme = false
    @State private var lightScheme = false
    @State private var darkScheme = false
    
    //MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                systemSchemeRow
                ligthSchemeRow
                darkSchemeRow
            }
            .navigationTitle("Display mode")
            .onAppear {
                onAppearTask()
            }
        }
    }
    
    //MARK: - View properties
    private var systemSchemeRow: some View {
        HStack {
            Text("System mode")
            
            Spacer()
            
            CheckboxButton(isOn: $systemScheme) {
                setOnlyModeSwitch(nil)
                settingsViewModel.setAppColorScheme(nil)
            }
        }
    }
    
    private var ligthSchemeRow: some View {
        HStack {
            Text("Light mode")
            
            Spacer()
            
            CheckboxButton(isOn: $lightScheme) {
                setOnlyModeSwitch(.light)
                settingsViewModel.setAppColorScheme(.light)
            }
        }
    }
    
    private var darkSchemeRow: some View {
        HStack {
            Text("Dark mode")
            
            Spacer()
            
            CheckboxButton(isOn: $darkScheme) {
                setOnlyModeSwitch(.dark)
                settingsViewModel.setAppColorScheme(.dark)
            }
        }
    }
    
    //MARK: - ViewBuilder methods
    
    //MARK: - Methods
    private func onAppearTask() {
        setOnlyModeSwitch(settingsViewModel.publishedAppColorScheme)
    }
    
    private func setOnlyModeSwitch(_ mode: ColorScheme?) {
        switch mode {
        case .light:
            systemScheme = false
            lightScheme = true
            darkScheme = false
        case .dark:
            systemScheme = false
            lightScheme = false
            darkScheme = true
        case nil:
            systemScheme = true
            lightScheme = false
            darkScheme = false
        case .some(_):
            systemScheme = true
            lightScheme = false
            darkScheme = false
        }
    }
}

#Preview {
    ColorModeView()
        .environmentObject(SettingsViewModel(
            settingsStorage: SettingsStorageMock(),
            dataStorage: DataStorageMock()
        ))
}
