//
//  Meeting_RecorderApp.swift
//  Meeting Recorder WatchKit Extension
//
//  Created by Spencer Steadman on 9/9/21.
//

import SwiftUI

@main
struct Meeting_RecorderApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
