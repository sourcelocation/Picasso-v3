// bomberfish
// GearSpinner.swift – Picasso
// created on 2023-12-10

import SwiftUI

struct GearSpinner: View {
    @Binding var rotate: Bool
    @State private var rotation = 0.0
    @State private var rotation2 = 0.0
    @State public var reversed: Bool = false
    var body: some View {
        ZStack(alignment: .center) {
            Image(systemName: "gear")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
                .opacity(0.8)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    if rotate {
                        withAnimation(.linear(duration: 1)
                            .speed(0.1).repeatForever(autoreverses: false)) {
                                rotation = reversed ? 360.0 : -360.0
                            }
                    }
                }
            Image(systemName: "gear")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
                .rotationEffect(.degrees(rotation2))
                .onAppear {
                    if rotate {
                        withAnimation(.linear(duration: 1)
                            .speed(0.1).repeatForever(autoreverses: false)) {
                                rotation2 = reversed ? -360.0 : 360.0
                            }
                    }
                }
        }
    }
}

#Preview {
    GearSpinner(rotate: .constant(true))
}
