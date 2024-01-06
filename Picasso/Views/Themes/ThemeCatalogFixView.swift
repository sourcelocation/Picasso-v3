//
//  ThemeCatalogFixView.swift
//  Picasso
//
//  Created by sourcelocation on 08/12/2023.
//

import SwiftUI

struct ThemeCatalogFixView: View {
    @Environment(\.dismiss) var dismiss
    @State var progress = 0.0
    @State var errorOccurred: Bool = false
    @State var errorMessage: String = unexpectedErrorString
    @State var complete: Bool = false
    var body: some View {
        VStack(spacing: 15) {
            if complete {
                Image(systemName: errorOccurred ? "xmark.circle" : "checkmark.circle")
                    .font(.system(size: 64))
                    .foregroundColor(Color(errorOccurred ? UIColor.systemRed : UIColor.systemGreen))
            } else {
                GearSpinner(rotate: .constant(true))
            }

            Text(complete ? (errorOccurred ? "An error occurred." : "Fixup complete") : "Fixing catalogs")
                .font(.title.bold())

            if errorOccurred {
                VStack(alignment: .leading) {
                    ScrollView(showsIndicators: true) {
                        Text(errorMessage)
                            .font(.system(.caption, design: .monospaced))
                            .padding(10)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: 320, maxHeight: 160, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, -20)
            } else {
                Text(complete ? "You can now close this sheet." : "Please wait...")
                    .font(.headline.weight(.regular))
            }
            if complete {
                Button(errorOccurred ? "Close OpenPicasso" : "OK") {
                    if errorOccurred {
                        exitApp()
                    }
                    dismiss()
                }
                .padding(.top, 20)
                .buttonStyle(.bordered)
                .tint(.accentColor)
                .controlSize(.large)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                    fix()
                } else {
                    complete = true
                    errorOccurred = true
                }
            }
        }
        .interactiveDismissDisabled(!complete)
    }

    func fix() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
            do {
                try CatalogThemeManager.shared.uncorruptCatalogs()
                UserDefaults.standard.set(false, forKey: "needsCatalogFixup")
                complete = true
            } catch {
                errorOccurred = true
                errorMessage = error.localizedDescription
//                UIApplication.shared.alert(body: "\(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ThemeCatalogFixView()
}
