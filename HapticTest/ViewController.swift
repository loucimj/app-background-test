//
//  ViewController.swift
//  HapticTest
//
//  Created by Javier Loucim - PayPal on 22/06/2021.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    var startTimestamp: Date?
    var endTimeStamp: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.gray
        checkPermission()
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: UIApplication.didBecomeActiveNotification, object: nil)

        simulateUseCase()
    }

    private func startBackgroundTask() {
        startTimestamp = Date()
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            self.finishBackgroundTask()
        }
    }

    private func finishBackgroundTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = .invalid

    }
    private func simulateUseCase() {
        startBackgroundTask()
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(3)) {
            self.sendLocalNotification()
            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
            print("haptics! \(Calendar.current.dateComponents([.second], from: self.startTimestamp ?? Date(), to: Date()).second ?? 0)")
            self.finishBackgroundTask()
        }
    }

    @objc private func reinstateBackgroundTask() {
        guard backgroundTask == .invalid else { return }
        simulateUseCase()
    }

    private func sendLocalNotification() {
        let notification = UNMutableNotificationContent()
        notification.title = "Titulo"
        notification.subtitle = "Haptics happened!"
        notification.userInfo["identity_id"] = UUID().uuidString
        notification.categoryIdentifier = "alarm"
        notification.sound = UNNotificationSound.defaultCritical
        self.scheduleLocalNotification(with: notification)
    }

    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestPermission()
            case .authorized: break
            case .denied:
            print("App don't have permissoon to display notifications")
            case .provisional:
                print("App don't have permissoon to display notifications")
            case .ephemeral:
                print("App don't have permissoon to display notifications")
            @unknown default:
                print("App don't have permissoon to display notifications")
            }
        }
    }

    private func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in

            if let error = error {
                print("\(error)")
            }
        }
    }

    private func scheduleLocalNotification(with content: UNMutableNotificationContent) {
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.1,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}

