// bomberfish
// GoghMainView.swift – Picasso
// created on 2023-11-10

import FluidGradient
import NavigationBackport
import SwiftUI

public struct GoghSetup: Identifiable {
    public var id = UUID()
    var previewImage: String
    var name: String
}

struct GoghMainView: View {
    let sampleSetups: [GoghSetup] = [.init(previewImage: "GoghSample1", name: "Sample 1"), .init(previewImage: "GoghSample2", name: "Sample 2")]
    @State var currentSetupName: String = ""
    @State var selectedSetupID: UUID = .init()
    var body: some View {
        GeometryReader { geometry in
//            Navigator {
                ZStack {
                    GoghBGView()
                    VStack {
                        LazyHStack {
                            TabView(selection: $selectedSetupID) {
                                ForEach(sampleSetups) { setup in
                                    GoghCardView(setup: setup)
                                        .tag(setup.id)
                                }
                                GoghAddCard()
                                    .tag(UUID())
                                    .clipShape(RoundedRectangle(cornerRadius: 28))
                                    .cornerRadius(28)
                                    .onTapGesture {
                                        UIApplication.shared.alert(body: "Not implemented")
                                    }
                                
                            }
                            .frame(minWidth: geometry.size.width, maxWidth: .infinity, maxHeight: geometry.size.height - 80)
                            .tabViewStyle(PageTabViewStyle())
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                        }
                        Text(currentSetupName)
                            .transition(.opacity)
                            .font(.title3.weight(.medium))
                    }
//                }
                .onAppear {
                    selectedSetupID = sampleSetups[0].id
                }
//                .onChange(of: selectedSetupID) {new in
//                    if sampleSetups.contains(where: {$0.id == new}) {
//                        withAnimation {
//                            currentSetupName = sampleSetups.first(where: {$0.id == new})?.name ?? "New"
//                        }
//                    } else {
//                        withAnimation {
//                            currentSetupName = "New"
//                        }
//                    }
//                }
                .navigationTitle("Gogh Main View")
            }
        }
    }
}

struct GoghCardView: View {
    public var setup: GoghSetup
    var body: some View {
        VStack {
            Image(setup.previewImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .scaleEffect(0.8)
        }
    }
}

struct GoghAddCard: View {
    @State var size: CGFloat = 1.0
    var body: some View {
        ZStack(alignment: .center) {
            Color(UIColor.secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .cornerRadius(28)
            ZStack {
                Circle()
                    .foregroundColor(.accentColor)
                    .frame(width: 55, height: 55)
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.black)
            }
            .scaleEffect(.init(size: size))
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
            .onChanged { _ in
                withAnimation(.spring()) {
                    Haptic.shared.play(.soft)
                    size = 0.8
                }
            }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        Haptic.shared.play(.light)
                        size = 1.0
                    }
                }
                )
            .padding(64)
            .cornerRadius(28)
            .clipShape(RoundedRectangle(cornerRadius: 28))
    }
}

struct GoghBGView: View {
    var body: some View {
        ZStack {
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            FluidGradient(blobs: [.accentColor, .teal, .accentColor, .teal, .accentColor, .teal, .accentColor, .teal, .accentColor, .teal, .accentColor, .teal], highlights: [.blue, .green, .blue, .green, .blue, .green, .blue, .green, .blue, .green, .blue, .green, .blue, .green, .blue, .green], speed: 0.8, blur: 0)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
                .opacity(0.7)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.thickMaterial)
        }
    }
}

struct GoghMainView_Previews: PreviewProvider {
    static var previews: some View {
        GoghMainView()
    }
}
