//
//  InDevelopmentView.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 04.10.2023.
//

import SwiftUI

struct InDevelopmentView: View {
    @State private var  imageTap = false
    
    var body: some View {
        VStack {
            
            if #available(iOS 17.0, *) {
                gearImage
                    .symbolEffect(.bounce, value: imageTap)
                    .onTapGesture {
                        imageTap.toggle()
                    }
            } else {
                gearImage
            }
            
            Text("In development")
                .font(.largeTitle)
                .fontWeight(.medium)
            
            Text("Comming soon")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }
    
    private var gearImage: some View {
        Image(systemName: "gearshape.2.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundStyle(SettingsStorage.pickedAppColor)
    }
}

#Preview {
    InDevelopmentView()
}
