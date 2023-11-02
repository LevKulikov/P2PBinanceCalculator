//
//  CheckboxButton.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 01.10.2023.
//

import SwiftUI

struct CheckboxButton: View {
    @Binding var isOn: Bool
    let completionHandler: (() -> Void)?
    @State private var didTap = false
    
    var body: some View {
        Button() {
            withAnimation {
                isOn.toggle()
                completionHandler?()
                didTap = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    didTap = false
                }
            }
        } label: {
            Image(systemName: isOn ? "checkmark.circle" : "circle")
                .foregroundStyle(SettingsStorage.pickedAppColor)
                .scaleEffect(1.5)
        }
        .controlSize(.large)
        .scaleEffect(didTap ? 0.8 : 1)
        .hoverEffect(.highlight)
        .contentShape(.hoverEffect, Circle())
    }
}

#Preview {
    CheckboxButton(isOn: .constant(true), completionHandler: nil)
}
