// bomberfish
// fancyViewInputModifier.swift – Picasso
// created on 2023-12-08

import SwiftUI

public struct fancyInputViewModifier: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        Group {
            content
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .dark ? .white.opacity(0.2): Color.accentColor.opacity(0.4), lineWidth: 2)
                )
                .background(
                    Color.accentColor.opacity(colorScheme == .dark ?0.075:0.0)
                )

                .cornerRadius(12)
        }.background(colorScheme == .dark ? Material.ultraThinMaterial:Material.thickMaterial).cornerRadius(12)
    }
}
