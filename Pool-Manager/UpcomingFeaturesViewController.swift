//
//  UpcomingFeaturesViewController.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 2/10/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import UIKit

class UpcomingFeaturesViewController: UIViewController {

  // MARK: User Controls
  
  @IBAction func btnDone(sender: AnyObject) {
    
    // Dismiss view controller and returning to login controller
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  // #MARK: - Standard ViewController Functions

  override func viewDidLoad() {
      super.viewDidLoad()

    
  }

}
