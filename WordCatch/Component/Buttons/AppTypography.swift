//
//  AppTypography.swift
//  WordCatch
//
//  Type scale for the app. Use these instead of inventing new sizes.
//

import SwiftUI

extension Font {
    /// 44pt heavy — splash titles, hero
    static let display = Font.system(size: 44, weight: .heavy, design: .rounded)

    /// 32pt heavy — screen titles
    static let h1 = Font.system(size: 32, weight: .heavy, design: .rounded)

    /// 22pt bold — section headers, card titles
    static let h2 = Font.system(size: 22, weight: .bold, design: .rounded)

    /// 17pt medium — body copy, descriptions
    static let bodyText = Font.system(size: 17, weight: .medium, design: .rounded)

    /// 13pt medium — captions, labels, helper text
    static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
}
