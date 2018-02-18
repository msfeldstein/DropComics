//
//  ViewController.swift
//  DropComic
//
//  Created by Mike Feldstein on 2/17/18.
//  Copyright © 2018 Mike Feldstein. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController {
  override func viewWillAppear(_ animated: Bool) {
    if DropboxClientsManager.authorizedClient != nil {
        performSegue(withIdentifier: "pushList", sender: nil)
    } else {
      print ("NOT LOADED")
    }
  }
  
  @IBAction func loginToDropbox() {
    print("LOGIN")
    DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                  controller: self,
                                                  openURL: { (url: URL) -> Void in
                                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                  })
  }
}

