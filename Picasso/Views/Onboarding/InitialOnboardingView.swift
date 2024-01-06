// bomberfish
// InitialOnboardingView.swift – Picasso
// created on 2023-12-08

import SwiftUI
import NavigationBackport

struct InitialOnboardingView: View {
    @State var path = NBNavigationPath()
    @AppStorage("firstOpen") private var firstTime: Bool = true
    var body: some View {
        Navigator {
            ZStack {
                OnboardingBGView()
                VStack {
                    Spacer()
                    Image("AppIcon-preview")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 128)
                        .padding(.bottom, 8)
                    Text("Welcome to Picasso")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                    NavigationLink(destination: OnboardingExploitSelect(), label: {
                        Text("Get Started")
                            .padding(4)
                            .frame(maxWidth: .infinity)
                            .font(.body.weight(.bold))
                            .background(Color.accentColor)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .cornerRadius(14)
                    })
                    .cornerRadius(14)
                    .padding(.horizontal)
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.thickMaterial)
            }
        }
    }
}

struct InitialOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        InitialOnboardingView()
    }
}
