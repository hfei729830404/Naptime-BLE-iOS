//
//  AppDelegate.swift
//  NaptimeBLE
//
//  Created by NyanCat on 25/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        SVProgressHUD.setMaximumDismissTimeInterval(2.0)
        SVProgressHUD.setDefaultMaskType(.black)
        return true
    }

}

