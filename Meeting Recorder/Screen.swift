//
//  Screen.swift
//  Meeting Recorder
//
//  Created by Spencer Steadman on 9/10/21.
//

import SwiftUI
import UIKit

extension UIScreen {
   static let width = UIScreen.main.bounds.size.width
   static let height = UIScreen.main.bounds.size.height
   static let size = UIScreen.main.bounds.size
    static let padding: CGFloat = 20.0
    static let cornerRadius: CGFloat = 25.0
    static let topEdgeInset: CGFloat = 50.0
    static let titleIcon: CGFloat = 32.0
    static let subtitleIcon: CGFloat = 26.0
}

// commonly used shadow
// .shadow(color: Color(group.backgroundColor).opacity(0.2), radius: 5, x: 0, y: 8)

