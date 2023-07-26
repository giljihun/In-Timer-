//
//  BGTaskScheduler.swift
//  In Timer!
//
//  Created by mobicom on 2023/07/26.
//

import Foundation
import BackgroundTasks

class BackgroundTask {
    static let shared = BackgroundTask()

    private let backgroundTaskIdentifier = "com.example.updateTargetTime"

    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleNextBackgroundTask()
        updateTargetTime()
        task.setTaskCompleted(success: true)
    }

    private func scheduleNextBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(selectedInterval * 60))
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Error scheduling background task: \(error)")
        }
    }

    private func updateTargetTime() {
        // Your existing updateTargetTime() implementation
    }
}
