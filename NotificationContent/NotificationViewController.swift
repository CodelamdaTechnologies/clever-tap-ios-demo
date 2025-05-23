//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by user on 21/05/25.
//

import CTNotificationContent
import CleverTapSDK

class NotificationViewController: CTNotificationViewController {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
    }
    
    override func userDidPerformAction(_ action: String, withProperties properties: [AnyHashable : Any]!) {
            print("userDidPerformAction \(action) with props \(String(describing: properties))")
        }
        
        // optional: implement to get notification response
        override func userDidReceive(_ response: UNNotificationResponse?) {
            print("Push Notification Payload \(String(describing: response?.notification.request.content.userInfo))")
            let notificationPayload = response?.notification.request.content.userInfo
            if (response?.actionIdentifier == "action_2") {
                CleverTap.sharedInstance()?.recordNotificationClickedEvent(withData: notificationPayload ?? "")
            }
        }

}
