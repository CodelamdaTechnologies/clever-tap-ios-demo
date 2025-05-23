//
//  AppDelegate.swift
//  clevertap-ios-demo
//
//  Created by user on 14/04/25.
//

import UIKit
import CleverTapSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CleverTapPushNotificationDelegate, CleverTapURLDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // CleverTap initialization
        CleverTap.autoIntegrate()
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        CleverTap.sharedInstance()?.setPushNotificationDelegate(self)
        CleverTap.enablePersonalization()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        // Track app installed event
        checkAndRecordAppInstallEvent()
        
        // Track app opened event
        CleverTap.sharedInstance()?.recordEvent("App Opened")
        
        return true
    }
    
    // Check if this is the first launch and record app install event
    private func checkAndRecordAppInstallEvent() {
        let userDefaults = UserDefaults.standard
        let isFirstLaunch = !userDefaults.bool(forKey: "HasLaunchedBefore")
        
        if isFirstLaunch {
            CleverTap.sharedInstance()?.recordEvent("App Installed")
            // Set flag indicating the app has been launched before
            userDefaults.set(true, forKey: "HasLaunchedBefore")
            userDefaults.synchronize()
            
            // Track app install with additional properties if needed
            let installProperties: [String: Any] = [
                "App Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
                "Build Number": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
                "Device Model": UIDevice.current.model,
                "OS Version": UIDevice.current.systemVersion
            ]
            
            CleverTap.sharedInstance()?.recordEvent("App Installed", withProps: installProperties)
        }
    }
    
    // MARK: - Push Notification Handling
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CleverTap.sharedInstance()?.setPushToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        CleverTap.sharedInstance()?.handleNotification(withData: notification.request.content.userInfo)
        // Log impression for the push notification
        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: notification.request.content.userInfo)
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        CleverTap.sharedInstance()?.handleNotification(withData: response.notification.request.content.userInfo)
        // Log click-through for the push notification
        CleverTap.sharedInstance()?.recordNotificationClickedEvent(withData: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    // MARK: - CleverTapPushNotificationDelegate
    func pushNotificationTapped(withCustomExtras customExtras: [AnyHashable : Any]!) {
        print("Push notification tapped with custom extras: \(String(describing: customExtras))")
    }
    
    // MARK: - CleverTapURLDelegate method
    public func shouldHandleCleverTap(_ url: URL?, for channel: CleverTapChannel) -> Bool {
        print("Handling URL: \(url!) for channel: \(channel)")
        return true
    }

    // MARK: - App Termination
    func applicationWillTerminate(_ application: UIApplication) {
        // Track app closed event
        CleverTap.sharedInstance()?.recordEvent("App Closed")
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
}
