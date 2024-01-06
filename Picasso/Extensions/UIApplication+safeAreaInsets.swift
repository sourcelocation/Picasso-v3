// bomberfish
// UIApplication+safeAreaInsets.swift – Picasso
// created on 2023-12-30

import UIKit

extension UIApplication {
    static var safeAreaInsets: UIEdgeInsets  {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets ?? .zero
    }
}
