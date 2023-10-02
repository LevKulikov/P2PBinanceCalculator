//
//  AppAppearanceView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 01.10.2023.
//

import SwiftUI

struct AppAppearanceView: View {
    //MARK: - Properties
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var pickedColor: Color = .white
    @State private var personalColor: Color = .purple
    
    //MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Pick App accent color")
                        .font(.title2)
                    Text("For better performance, App will display new color after restart")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                    
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 110, maximum: 200))],
                        spacing: 14
                    ) {
                        createColorCellButton(title: "Default", color: AppAppearanceVariables.defaultColor)
                        createColorCellButton(title: "Red", color: AppAppearanceVariables.redColor)
                        createColorCellButton(title: "Blue", color: AppAppearanceVariables.blueColor)
                        createColorCellButton(title: "Black/White", color: AppAppearanceVariables.blackAndWhiteColor)
                        colorPickerCellButton
                    }
                    
                    
                }
                .padding()
                .navigationTitle("App appearance")
                .onAppear {
                    onAppearTask()
                }
            }
        }
    }
    
    //MARK: - View properties
    private var colorPickerCellButton: some View {
        VStack {
            let isPickedColor = pickedColor.accessibilityName == personalColor.accessibilityName
            
            personalColor
                .frame(width: 90, height: 90)
                .cornerRadius(18.0)
                .overlay(RoundedRectangle(cornerRadius: 18.0).stroke(Color.white, style: StrokeStyle(lineWidth: 4)))
                .padding(9)
                .background(AngularGradient(gradient: Gradient(colors: [.red,.yellow,.green,.blue,.purple,.pink]), center:.center).cornerRadius(18))
                .overlay(ColorPicker("", selection: $personalColor).labelsHidden().opacity(0.015).scaleEffect(3.5))
                .shadow(color: isPickedColor ? personalColor : Color(.sRGBLinear, white: 0, opacity: 0.33), radius: isPickedColor ? 10 : 5)
                .scaleEffect(isPickedColor ? 1.02 : 1)
            
            Text("Personal")
                .font(.subheadline)
                .foregroundStyle(isPickedColor ? .primary : .secondary)
                .scaleEffect(isPickedColor ? 1.05 : 1)
                .frame(maxWidth: 110)
                .multilineTextAlignment(.center)
        }
        .hoverEffect(.lift)
        .onChange(of: personalColor) { value in
            withAnimation {
                settingsViewModel.setAppColor(personalColor)
                pickedColor = personalColor
            }
        }
    }
    
    //MARK: - ViewBuilder methods
    /// Creates cell button for represantation app color to set. By tapping sets picked color in the settings
    /// - Parameters:
    ///   - title: Title for the cell
    ///   - color: Color to represant
    /// - Returns: Color cell button with color and title
    @ViewBuilder
    private func createColorCellButton(title: String, color: Color) -> some View {
        let isPickedColor = pickedColor.accessibilityName == color.accessibilityName
        
        VStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(color)
                .frame(width: 110, height: 110)
                .shadow(color: isPickedColor ? color : Color(.sRGBLinear, white: 0, opacity: 0.33), radius: isPickedColor ? 10 : 5)
                .scaleEffect(isPickedColor ? 1.02 : 1)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(isPickedColor ? .primary : .secondary)
                .scaleEffect(isPickedColor ? 1.05 : 1)
                .frame(maxWidth: 110)
        }
        .hoverEffect(.lift)
        .onTapGesture {
            withAnimation {
                settingsViewModel.setAppColor(color)
                pickedColor = color
            }
        }
    }
    
    //MARK: - Methods
    private func onAppearTask() {
        pickedColor = settingsViewModel.publishedAppColor
        if !AppAppearanceVariables
            .availableDefaultColors
            .map({$0.accessibilityName})
            .contains(pickedColor.accessibilityName) {
            personalColor = pickedColor
        }
    }
}

#Preview {
    AppAppearanceView()
        .environmentObject(SettingsViewModel(
            settingsStorage: SettingsStorageMock(),
            dataStorage: DataStorageMock()
        ))
}
