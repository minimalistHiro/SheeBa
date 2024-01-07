//
//  SheeBaApp.swift
//  SheeBa
//
//  Created by 金子広樹 on 2024/01/04.
//

import SwiftUI
import FirebaseCore

@main
struct SheeBaApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
