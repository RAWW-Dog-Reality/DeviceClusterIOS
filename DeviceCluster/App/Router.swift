//
//  Router.swift
//  DeviceCluster
//
//  Created by Daniyar Kurmanbayev on 2025-08-21.
//

import Foundation
import SwiftUI
import Combine

final class Router: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: SheetRoute?
    @Published var fullScreen: FullScreenRoute?

    enum Route: Hashable {
    }

    enum SheetRoute: Identifiable {
        var id: String { String(describing: self) }
    }

    enum FullScreenRoute: Identifiable {
        var id: String { String(describing: self) }
    }

//    Push
    
//    Present
    private func presentFullScreen(_ screen: FullScreenRoute, animated: Bool = true) {
        if animated {
            fullScreen = screen
        } else {
            var t = Transaction()
            t.disablesAnimations = true
            t.animation = nil
            withTransaction(t) { fullScreen = screen }
        }
    }

//    Pop
    func pop() { path.removeLast() }
    func back(_ n: Int = 1) { path.removeLast(min(n, path.count)) }
    func popToRoot() { path = NavigationPath() }

//    Dismiss
    func dismissSheet() { sheet = nil }
    func dismissFullScreen(animated: Bool = true) {
        if animated {
            fullScreen = nil
        } else {
            withTransaction(Transaction(animation: nil)) {
                fullScreen = nil
            }
        }
    }
}
