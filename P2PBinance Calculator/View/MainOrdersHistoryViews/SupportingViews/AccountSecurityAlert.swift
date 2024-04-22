//
//  AccountSecurityAlarm.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 21.04.2024.
//

import SwiftUI

struct AccountSecurityAlarm: View {
    var namespace: Namespace.ID
    @Binding var showAlarm: Bool
    var cofirmationHandler: () -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Material.ultraThin)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut) {
                        showAlarm.toggle()
                    }
                }
            
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundStyle(SettingsStorage.pickedAppColor)
                    .transition(.move(edge: .bottom))
                
                Text("Provide API with read rights __only__!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .transition(.move(edge: .bottom))
                    .padding(.horizontal, 40)
                    .padding(.bottom)
                
                Button {
                    cofirmationHandler()
                    showAlarm.toggle()
                } label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 30)
                .tint(SettingsStorage.pickedAppColor)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .matchedGeometryEffect(id: "confirmButton", in: namespace)
                
                Button {
                    showAlarm.toggle()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 30)
                .tint(Color.red)
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
        }
    }
}

#Preview {
    @Namespace var namespace
    @State var showAlarm = true
    
    return AccountSecurityAlarm(namespace: namespace, showAlarm: $showAlarm, cofirmationHandler: {})
}
