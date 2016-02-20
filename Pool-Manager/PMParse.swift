//
//  PMParse.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 1/13/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import UIKit
import Foundation
import CoreData

extension PMClient {
  
  // Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
  var sharedContext: NSManagedObjectContext {
    return CoreDataStackManager.sharedInstance().managedObjectContext
    
  }
  
  
  // Function used to retrieve customer informarion (i.e. name, address and phone)
  func retreivePoolInformation(completionHandler: (success: Bool, result: [Customer]?, errorCode: String?, errorText: String?) -> Void) {
    
    // 1 - Ensure user ID and password parameters are passed in from the calling function
    
    // 2 & 3 - Build the URL and configure the request
    let request = NSMutableURLRequest(URL: NSURL(string: PMClient.Constants.parseGetCustomerLocationsURL)!)
    request.addValue(PMClient.Constants.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(PMClient.Constants.parseRestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    
    // 4 - Make the request
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        
        // set status code for Alert message to user - network error
        completionHandler(success: false, result: nil, errorCode: "Network Error", errorText: "The Internet connection appears to be offline.")
        
        print(error!)
        
      } else {
        
        // 5 - Parse the data and create a dictionary object to hold the data
        let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
        
        print("parsed result: \(parsedResult)")
        
        // 6A - Use the data:  Get the session dictionary
        if let results = parsedResult.valueForKey("results") as? [[String:AnyObject]] {
          
          if results.isEmpty {
            // check if results are empty
            print("Nothing Found")
            completionHandler(success: false, result: nil, errorCode: "Application Initialization Error", errorText: "Customer information could not be found.")
            
          } else {
            // customer data was found, save data into an array and pass back to calling function to process.
            let customersInformation = Customer.customersFromResults(results, context: self.sharedContext)
            
            completionHandler(success: true, result: customersInformation, errorCode: nil, errorText: nil)
          }
          
        } else {
          dispatch_async(dispatch_get_main_queue()) {
            
            // set status code for Alert message to user - network error
            completionHandler(success: false, result: nil, errorCode: "Application Initialization Error", errorText: "Customer information could not be loaded.")
            
            print("Could not find customer information in \(parsedResult)")
          }
        }
      }
    }
    
    // Start the request
    task.resume()
  }
  
  
  
  // Function used to post maintenance request to Parse DB
  func postMaintenanceRequest(reqPoolName: String, reqWorkRequested: String, reqSpecialInstructions: String, reqPriority: String, reqContactName: String, reqContactNumber: String, submitterName: String, completionHandler: (success: Bool, errorCode: String?, errorText: String?) -> Void) {
    
    // 1 - parameters are passed in.
    
    // 2 & 3 - Build the URL and configure the request
    let request = NSMutableURLRequest(URL: NSURL(string: PMClient.Constants.parsePostMaintenanceRequestURL)!)
    request.HTTPMethod = "POST"
    request.addValue(PMClient.Constants.parseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(PMClient.Constants.parseRestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = "{\"CustomerName\": \"\(reqPoolName)\", \"WorkRequested\": \"\(reqWorkRequested)\", \"SpecialInstructions\": \"\(reqSpecialInstructions)\",\"Priority\": \"\(reqPriority)\", \"ContactName\": \"\(reqContactName)\",\"ContactNumber\": \"\(reqContactNumber)\", \"SubmitterName\": \"\(submitterName)\"}".dataUsingEncoding(NSUTF8StringEncoding)
    
    // 4 - Make the request
    let task = session.dataTaskWithRequest(request) { data, response, error in
      if error != nil {
        
        // set status code for Alert message to user - network error
        completionHandler(success: false, errorCode: "Network Error", errorText: "The Internet connection appears to be offline.")
        
        print(error!)
        
      } else {
        
        // 5 - Parse the subset  of the original data and create a dictionary object to hold the data
        let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary

        print("parsed result: \(parsedResult)")
        
        // 6A - Use the data:  Get the session/account dictionary and get the account number
        if let resultsDictionary = parsedResult.valueForKey("createdAt") as? String {
          print("Maintenance Request successfully submitted: \(resultsDictionary)")
          
          completionHandler(success: true, errorCode: nil, errorText: nil)
          
        } else {
          // set status code for Alert message to user - invalid credentials
          completionHandler(success: false, errorCode: "Error", errorText: "Your request could not be submitted.")
          
          print("Could not submit maintenance request - Error Info: \(parsedResult)")
        }
      }
    }
    
    // Start the request
    task.resume()
    
  }
  
}
