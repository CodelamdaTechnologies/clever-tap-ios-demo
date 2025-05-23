//
//  DeviceInfo.swift
//  clevertap-ios-demo
//
//  Created by user on 22/05/25.
//

import UIKit

struct DeviceInfo {
    static var info: [String: String] {
        let device = UIDevice.current
        return [
            "deviceType": "iOS",
            "deviceModel": device.model,
            "osVersion": device.systemVersion,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]
    }
}

