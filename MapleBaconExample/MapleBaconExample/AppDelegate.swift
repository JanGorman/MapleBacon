//
// Copyright (c) 2015 Zalando SE. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        adjustAppearance()

        return true
    }

    func adjustAppearance() {
        let lightColor = UIColor(red: 127 / 255, green: 187 / 255, blue: 154 / 255, alpha: 1)
        UINavigationBar.appearance().barTintColor = lightColor
        UITabBar.appearance().tintColor = lightColor

        let darkColor = UIColor(red: 14 / 255, green: 43 / 255, blue: 57 / 255, alpha: 1)
        UINavigationBar.appearance().tintColor = darkColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: darkColor]
        UITabBar.appearance().barTintColor = darkColor
    }

}

