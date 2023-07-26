//
//  TimeSpeakerApp.swift
//  TimeSpeaker
//
//  Created by 길지훈 on 2023/06/01.
//

import SwiftUI
import UserNotifications

@main
struct TimeSpeakerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 앱이 시작될 때 알림 권한을 확인하고 요청합니다.
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // 알림 권한이 허용되지 않은 경우, 권한 요청을 시작합니다.
                requestNotificationAuthorization()
            case .authorized:
                print("알림 권한이 허용되어 있습니다.")
            case .denied:
                print("알림 권한이 거부되었습니다.")
                // 권한이 거부된 경우에 사용자에게 설명을 제공하거나 다른 방법으로 알림을 제공해야 할 수 있습니다.
            case .provisional:
                print("알림 권한이 임시적으로 허용되었습니다.")
            @unknown default:
                fatalError("새로운 권한 상태가 추가되었습니다.")
            }
        }

        return true
    }
}

func requestNotificationAuthorization() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        if granted {
            print("알림 권한이 허용되었습니다.")
            // 권한이 허용된 경우에 추가적인 설정이나 처리를 수행할 수 있습니다.
        } else {
            print("알림 권한이 거부되었습니다.")
            // 권한이 거부된 경우에 사용자에게 설명을 제공하거나 다른 방법으로 알림을 제공해야 할 수 있습니다.
        }
    }
}
