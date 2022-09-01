//
//  color.swift
//  FirebaseComms
//
//  Created by Peter Gao on 8/24/22.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let background = Color("BackgroundColor")
    let foreground = Color("ForegroundColor")
    let accent = Color("AccentColor")
    let contrast = Color("ContrastColor")
    let attendanceColors = [Color("AccentColor"), Color.green, Color.red]
}
