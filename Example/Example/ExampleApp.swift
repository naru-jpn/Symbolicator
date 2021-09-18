//
//  ExampleApp.swift
//  Example
//
//  Created by Naruki Chigira on 2021/09/18.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem, addition: { })
        }
    }
}
