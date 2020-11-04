//
//  AppDelegate.swift
//  LoveCycleView
//
//  Created by 童川 on 2019/12/2.
//  Copyright © 2019 Tom. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = UINavigationController.init(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        return true
    }
}

