//
//  AppIconChange.swift
//  Picasso
//
//  Created by sourcelocation on 23/08/2023.
//

import Foundation

public struct AppIconChange {
    var app: SBApp
    var icon: ThemedIcon?

    init(app: SBApp, icon: ThemedIcon?) {
        self.app = app
        self.icon = icon
    }
}
