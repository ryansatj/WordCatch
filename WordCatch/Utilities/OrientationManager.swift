//
//  OrientationManager.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//

import Foundation
import SwiftUI

class OrientationManager {

    static let shared = OrientationManager()

    func lockLandscape() {

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        windowScene.requestGeometryUpdate(
            .iOS(interfaceOrientations: .landscape)
        )

        windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }

    func lockPortrait() {

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        windowScene.requestGeometryUpdate(
            .iOS(interfaceOrientations: .portrait)
        )

        windowScene.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
