// bomberfish
// ToolsView.swift – Picasso
// created on 2023-12-05

import SwiftUI
import NavigationBackport

struct ToolsView: View {
    var body: some View {
        Navigator {
            List {
                NavigationLink(destination: AirTrollerView()) {
                    Label("AirTroller", systemImage: "antenna.radiowaves.left.and.right.circle")
                }
                #if DEBUG
                NavigationLink("Gogh") {
                    GoghMainView()
                }
                #endif
            }
            .navigationTitle("Toolbox")
        }
    }
}
