//
//  AppDelegate.swift
//  Dokgi
//
//  Created by 송정훈 on 6/3/24.
//

import CoreData
import IQKeyboardManagerSwift
import NotificationCenter
import UIKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //런치스크린 시간
        sleep(1)
        
        let viewModel = DayTimeViewModel()
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { didAllow, _ in
                if didAllow {
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notification.rawValue)
                    if UserDefaults.standard.bool(forKey: UserDefaultsKeys.lauchedBefore.rawValue) == false {
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.remindSwitch.rawValue)
                        viewModel.sendLocalPushRemind(identifier: "remindTime", time: [3, 0, 1])
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.writeSwitch.rawValue)
                        viewModel.sendLocalPushWrite(identifier: "writeTime", time: [3, 0, 1], day: [1, 1, 1, 1, 1, 1, 1])
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.lauchedBefore.rawValue)
                    }
                } else {
                    UserDefaults.standard.set(false, forKey: UserDefaultsKeys.notification.rawValue)
                    if UserDefaults.standard.bool(forKey: UserDefaultsKeys.lauchedBefore.rawValue) == false {
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.remindSwitch.rawValue)
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.writeSwitch.rawValue)
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.lauchedBefore.rawValue)
                    }
                }
            }
        )
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.remindSwitch.rawValue) == true {
            viewModel.sendLocalPushRemind(identifier: "remindTime", time: UserDefaults.standard.array(forKey: UserDefaultsKeys.remindTime.rawValue) as? [Int] ?? [3, 00, 1])
        }
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.writeSwitch.rawValue) == true {
            viewModel.sendLocalPushWrite(identifier: "writeTime", time: UserDefaults.standard.array(forKey: UserDefaultsKeys.writeTime.rawValue) as? [Int] ?? [3, 00, 1], day: UserDefaults.standard.array(forKey: UserDefaultsKeys.writeWeek.rawValue) as? [Int] ?? [1, 1, 1, 1, 1, 1, 1])
        }
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.resignOnTouchOutside = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Dokgi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 앱이 foreground에 있을때 알림이 오면 이 메서드 호출
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 푸쉬가 오면 다음을 표시하라는 뜻
        // 배너는 배너, 뱃지는 앱 아이콘에 숫자 뜨는것, 사운드는 알림 소리, list는 알림센터에 뜨는거
        completionHandler([.banner, .sound, .list])
    }
}
