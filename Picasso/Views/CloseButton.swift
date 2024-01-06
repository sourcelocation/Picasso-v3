// bomberfish
// CloseButton.swift – Picasso
// created on 2023-12-14

import SwiftUI

struct CloseButton: View {
    @Environment(\.colorScheme) var cs
    var body: some View {
        Circle()
            .fill(cs == .dark ? Color(UIColor.secondarySystemGroupedBackground) : Color(UIColor.systemGray).opacity(0.8))
            .frame(width: 26, height: 26)
            .overlay(
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(cs == .dark ? Color(UIColor.label) : Color(UIColor.systemBackground))
            )
    }
}
#Preview {
    CloseButton()
}
