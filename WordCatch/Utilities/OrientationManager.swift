//
//  OrientationManager.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//
//  Locks the app to a specific orientation. Works alongside the
//  AppDelegate hook in WordCatchApp.swift — the delegate reads
//  `mask` to tell iOS which orientations are currently allowed.
//  Without that delegate, requestGeometryUpdate is silently ignored.
//

import SwiftUI
import UIKit

final class OrientationManager {

    static let shared = OrientationManager()

    //update
    
    // Current allowed orientations. Read by AppDelegate's
    // supportedInterfaceOrientationsFor:.
    var mask: UIInterfaceOrientationMask = .all

    func lockLandscape() {
        mask = .landscape
        apply(.landscape)
    }

    func lockPortrait() {
        mask = .portrait
        apply(.portrait)
    }

    private func apply(_ orientations: UIInterfaceOrientationMask) {
        guard let scene = UIApplication.shared.connectedScenes
            .first as? UIWindowScene else { return }

        scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientations))
        scene.keyWindow?.rootViewController?
            .setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}
