//
//  Other.swift
//  P2PBinance Calculator
//
//  Created by Лев Куликов on 05.08.2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import UIKit

extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    var currencyRU: String {
        return String(format: "%.2f", locale: Locale(identifier: "ru"), self)
    }
}

extension Date {
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return Calendar.current.date(byAdding: .second, value: -1, to: self.dayAfter.startOfDay)!
    }
}

extension View {
    @ViewBuilder
    func applyTextColor(_ color: Color) -> some View {
        if let pickedColorScheme = SettingsStorage.pickedAppColorScheme {
            if pickedColorScheme == .light {
                self.colorInvert().colorMultiply(color)
            } else {
                self.colorMultiply(color)
            }
        } else {
            if UITraitCollection.current.userInterfaceStyle == .light {
                self.colorInvert().colorMultiply(color)
            } else {
                self.colorMultiply(color)
            }
        }
    }
    
    @ViewBuilder
    func bottomSheet<Content: View>(
        presentationDetents: Set<PresentationDetent>,
        isPresented: Binding<Bool>,
        dragIndicator: Visibility = .visible,
        sheetCornerRadius: CGFloat?,
        largestUndimmedIdentifier: UISheetPresentationController.Detent.Identifier = .large,
        isTransparentBG: Bool = false,
        interactiveDisabled: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            onDismiss()
        } content: {
            content()
                .presentationDetents(presentationDetents)
                .presentationDragIndicator(dragIndicator)
                .interactiveDismissDisabled(interactiveDisabled)
                .onAppear {
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                        return
                    }
                    DispatchQueue.main.async {
                        if let viewController = windowScene.windows.first?.rootViewController?.presentedViewController,
                           let sheet = viewController.presentationController as? UISheetPresentationController {
                            if isTransparentBG {
                                viewController.view.backgroundColor = .clear 
                            }
                            
                            viewController.presentedViewController?.view.tintAdjustmentMode = .normal
                            sheet.largestUndimmedDetentIdentifier = largestUndimmedIdentifier
                            sheet.preferredCornerRadius = sheetCornerRadius
                        } else {
                            print("NO VIEW CONTROLLER FOUND")
                        }
                    }
                }
        }
    }
}

extension UIColor {
    class func color(data: Data) -> UIColor? {
        try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
    }

    func encode() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}

extension Color {
    var accessibilityName: String {
        return UIColor(self).accessibilityName
    }
}

func copyAsPlainText(_ value: String) {
    let clipboard = UIPasteboard.general
    clipboard.setValue(value, forPasteboardType: UTType.plainText.identifier)
}
