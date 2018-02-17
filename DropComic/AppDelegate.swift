//
//  AppDelegate.swift
//  DropComic
//
//  Created by Mike Feldstein on 2/17/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    DropboxClientsManager.setupWithAppKey("8njyxn4yy4uh0b0")
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    if let authResult = DropboxClientsManager.handleRedirectURL(url) {
        switch authResult {
        case .success:
            print("Success! User is logged into Dropbox.")
        case .cancel:
            print("Authorization flow was manually canceled by user!")
        case .error(_, let description):
            print("Error: \(description)")
        }
    }
    return true
  }
}

