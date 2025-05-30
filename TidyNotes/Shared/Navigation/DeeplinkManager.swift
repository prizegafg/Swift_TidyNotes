//
//  DeeplinkManager.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 27/05/25.
//

import Foundation
import SwiftUI

enum DeepLink {
    case openTaskDetail(taskId: UUID)
}

final class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()

    @Published var pendingDeepLink: DeepLink?

    private init() {}

    func handle(_ deepLink: DeepLink) {
        pendingDeepLink = deepLink
    }

    func consume() -> DeepLink? {
        let link = pendingDeepLink
        pendingDeepLink = nil
        return link
    }
}
