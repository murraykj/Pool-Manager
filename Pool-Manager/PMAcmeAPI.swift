//
//  PMAcmeAPI.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 1/30/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import Foundation

import UIKit
import Foundation

extension PMClient {

  // Function used to retrieve user information from Microsoft Azure API and GoDaddy DB
  func retreiveUserInformation(userID: String, password: String, completionHandler: (result: User?, errorCode: String?, errorText: String?) -> Void) {
    
    // 1 - Ensure user ID and password parameters are passed in from the calling function
//    print("User ID: \(userID)")
//    print("Password: \(password)")
    
    // 2 - Build URL strng
    let urlString : String = PMClient.Constants.parseValidateUserURL + userID + "&password=" + password + "&APIKey=" + PMClient.Constants.acmeAPIKey
    
    // 3 - configure the request
    let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
    
    // 4 - Make the request
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        
        // set status code for Alert message to user - network error
        completionHandler(result: nil, errorCode: "Network Error", errorText: "The Internet connection appears to be offline.")
        
        print(error!)
        
      } else {
        
        // 5 - Parse the data and create a structure object to hold the data
        let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
//        let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! AnyObject  // saved for use with new API
        
        
        print("parsed result: \(parsedResult)")
        
        // check to see if data was returned
        if let status = parsedResult["Status"]! as? String {
        
          // capture user data
          let currentUser = User(dictionary: parsedResult as! [String : AnyObject])

          // print status that was returned back
          print("Status: \(status)")
          
          // pass user data back to calling function
          completionHandler(result: currentUser, errorCode: nil, errorText: nil)
          
        } else {
          dispatch_async(dispatch_get_main_queue()) {
            
            // set status code for Alert message to user - network error
            completionHandler(result: nil, errorCode: "Data Retreival Error", errorText: "User information could not be downloaded.")
            
            print("Could not find user information in \(parsedResult)")
          }
        }
      }
    }
    
    // Start the request
    task.resume()
  }

}

