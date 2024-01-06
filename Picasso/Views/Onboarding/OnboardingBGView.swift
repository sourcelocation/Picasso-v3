// bomberfish
// OnboardingBGView.swift – Picasso
// created on 2023-12-08

import SwiftUI
import FluidGradient

struct OnboardingBGView: View { // consistent bg between both views :trol:
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea(.all)
            FluidGradient(blobs: [.accentColor, .teal, .accentColor, .teal, .accentColor, .teal], highlights: [.blue, .green, .blue, .green, .blue, .green, .blue, .green], speed: 0.5, blur: 0.8)
                .ignoresSafeArea(.all)
        }
    }
}
