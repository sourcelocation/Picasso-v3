// bomberfish
// AutoPad.swift – Picasso
// created on 2023-12-30

import SwiftUI

struct AutoPad: ViewModifier {
    func body(content: Content) -> some View {
        let hasHomeIndicator = UIApplication.safeAreaInsets.bottom - 88 > 20
        content
            .padding(.bottom, hasHomeIndicator ? 48 : 22)
    }
}
