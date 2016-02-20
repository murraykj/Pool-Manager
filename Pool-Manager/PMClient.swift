//
//  PMClient.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 1/13/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import Foundation
import UIKit

class PMClient : NSObject {
  
  /* Shared session */
  var session: NSURLSession
  
  override init() {
    session = NSURLSession.sharedSession()
    super.init()
  }
  
  // Shared Instance
  static let sharedInstance = PMClient()
  
}