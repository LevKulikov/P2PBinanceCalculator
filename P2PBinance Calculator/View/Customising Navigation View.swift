//
//  Customising Navigation View.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 06.08.2023.
//

import Foundation
import SwiftUI
import UIKit

struct NaviBarVersionModifier : ViewModifier {
    var title : String
    var displayMode: NavigationBarItem.TitleDisplayMode
       
    @ViewBuilder
    func body(content: Content) -> some View {

        if #available(iOS 14, *) {
             content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode( displayMode)
        }
        else {
            content.navigationBarTitle(title,displayMode: displayMode)
        }
    }
}

extension View {
    func navigation (title : String ,
      displayMode : NavigationBarItem.TitleDisplayMode = .automatic) -> some View{
        
        self.modifier( NaviBarVersionModifier(title: title, displayMode: displayMode))
    }
}

class Theme {
    static func navigationBarColors(background : UIColor?,
       titleColor : UIColor? = nil, tintColor : UIColor? = nil ){
        
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = background ?? .clear
        
        navigationAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .black]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .black]
       
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance

        UINavigationBar.appearance().tintColor = tintColor ?? titleColor ?? .black
    }
}
