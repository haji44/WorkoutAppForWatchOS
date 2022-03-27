//
//  MyWorksOutsApp.swift
//  MyWorksOuts WatchKit Extension
//
//  Created by kitano hajime on 2022/03/16.
//

import SwiftUI

@main
struct MyWorksOutsApp: App {
    @StateObject var workoutManger = WorkoutManager()

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
            .sheet(isPresented: $workoutManger.showingSummaryView) {
                SummaryView()
            }
            .environmentObject(workoutManger)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
