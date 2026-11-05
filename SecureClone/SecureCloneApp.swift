//
//  SecureCloneApp.swift
//  SecureClone
//
//  Secure media offload tool for the film industry.
//  Read source once → fan out to multiple drives → verify with xxHash64 → MHL + logs.
//

import SwiftUI

@main
struct SecureCloneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowResizability(.contentMinSize)
    }
}
