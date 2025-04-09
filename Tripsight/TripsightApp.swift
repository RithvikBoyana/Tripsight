//
//  TripsightApp.swift
//  Tripsight
//
//  Created by Rithvik Boyana on 4/9/25.
//

import SwiftUI

@main
struct TripsightApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(networkService: NetworkService.shared)
        }
    }
}
