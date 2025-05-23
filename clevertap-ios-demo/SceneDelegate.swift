//
//  SceneDelegate.swift
//  clevertap-ios-demo
//
//  Created by user on 14/04/25.
//

import UIKit
import CleverTapSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let rootViewController = determineInitialViewController()
        window.rootViewController = rootViewController
        self.window = window
        window.makeKeyAndVisible()
    }
    
    private func determineInitialViewController() -> UIViewController {
        // Check if user has given GDPR consent
        let hasGivenConsent = UserDefaults.standard.object(forKey: "userConsent") != nil
        
        // Check if user has completed signup
        let userEmail = UserDefaults.standard.string(forKey: "userEmail")
        let userUUID = UserDefaults.standard.string(forKey: "userUUID")
        let anonymousUUID = UserDefaults.standard.string(forKey: "anonymousUUID")
        let hasCompletedAuth = userEmail != nil || anonymousUUID != nil
        
        // Determine flow based on user state
        if !hasGivenConsent {
            // User hasn't given GDPR consent yet - show GDPR screen
            return GDPRConsentViewController()
        } else if !hasCompletedAuth {
            // User gave consent but hasn't completed auth - show signup/auth screen
            return AuthViewController()
        } else {
            // User has completed the full flow - go directly to dashboard
            recordAppReturnEvent()
            return DashboardViewController()
        }
    }
    
    private func recordAppReturnEvent() {
        // Record that user is returning to the app
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        let userName = UserDefaults.standard.string(forKey: "userName") ?? "Anonymous"
        let lastOpenDate = UserDefaults.standard.object(forKey: "lastAppOpenDate") as? Date
        
        var props: [String: Any] = [
            "user_email": userEmail,
            "user_uuid": userUUID,
            "user_name": userName,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            "platform": "iOS",
            "return_session": true
        ]
        
        // Calculate days since last open if available
        if let lastOpen = lastOpenDate {
            let daysSinceLastOpen = Calendar.current.dateComponents([.day], from: lastOpen, to: Date()).day ?? 0
            props["days_since_last_open"] = daysSinceLastOpen
            
            // Categorize return frequency
            switch daysSinceLastOpen {
            case 0:
                props["return_frequency"] = "same_day"
            case 1:
                props["return_frequency"] = "daily"
            case 2...7:
                props["return_frequency"] = "weekly"
            case 8...30:
                props["return_frequency"] = "monthly"
            default:
                props["return_frequency"] = "long_time"
            }
        } else {
            props["return_frequency"] = "first_time"
        }
        
        // Record the return event
        CleverTap.sharedInstance()?.recordEvent("App_Returned", withProps: props)
        
        // Update last open date
        UserDefaults.standard.set(Date(), forKey: "lastAppOpenDate")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Initialize In-App Notifications when app becomes active
        CleverTap.sharedInstance()?.resumeInAppNotifications()
        
        // Track app foreground event
        CleverTap.sharedInstance()?.recordEvent("App Foregrounded")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Pause In-App Notifications when app becomes inactive
        CleverTap.sharedInstance()?.suspendInAppNotifications()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        // Record foreground event with session info
        let backgroundTime = UserDefaults.standard.object(forKey: "backgroundTimestamp") as? Date
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"  // CHANGED
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"

        var props: [String: Any] = [
            "platform": "iOS",
            "session_type": "foreground",
            "user_email": userEmail,
            "user_uuid": userUUID
        ]
        
        if let bgTime = backgroundTime {
            let backgroundDuration = Date().timeIntervalSince(bgTime)
            props["background_duration"] = backgroundDuration
            
            // Categorize background duration
            switch backgroundDuration {
            case 0..<60:
                props["background_category"] = "quick_switch"
            case 60..<300:
                props["background_category"] = "short_break"
            case 300..<1800:
                props["background_category"] = "medium_break"
            default:
                props["background_category"] = "long_break"
            }
        }
        
        CleverTap.sharedInstance()?.recordEvent("App_Foregrounded", withProps: props)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Track app background event
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"  // CHANGED
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        let props: [String: Any] = [
            "platform": "iOS",
            "session_type": "background",
            "background_timestamp": Date(),
            "user_email": userEmail,
            "user_uuid": userUUID
        ]
        
        CleverTap.sharedInstance()?.recordEvent("App_Backgrounded", withProps: props)
        
        // Store background timestamp for calculating background duration
        UserDefaults.standard.set(Date(), forKey: "backgroundTimestamp")
    }
}

