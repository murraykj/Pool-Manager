//
//  MenuTableViewController.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 2/4/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import UIKit
import CoreData

class MenuTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  
  // #MARK: - Core Data Components (Documents Directory)
  
  // A convenience property to set the filepath to store the map region
  var filePath : String {
    let manager = NSFileManager.defaultManager()
    let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
    return url.URLByAppendingPathComponent("userInfoArchive").path!
  }
  
  
  // MARK: - Core Data Convenience (SQL Lite)
  
  // Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
  lazy var sharedContext: NSManagedObjectContext =  {
    return CoreDataStackManager.sharedInstance().managedObjectContext
  }()
  
  
  func saveContext() {
    CoreDataStackManager.sharedInstance().saveContext()
  }
  
  // declaration of lazy var fetchedResultsController
  lazy var fetchedResultsController: NSFetchedResultsController = {
    
    let fetchRequest = NSFetchRequest(entityName: "Customer")
    
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "custName", ascending: true)]
    
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
      managedObjectContext: self.sharedContext,
      sectionNameKeyPath: nil,
      cacheName: nil)
    
    return fetchedResultsController
    
  }()
  
  
  
  // MARK: Standard ViewController Functions
  
  override func viewDidLoad() {
        super.viewDidLoad()
    
      // invoke fetchedResultsController to retreive all customers
      do {
      try fetchedResultsController.performFetch()
      } catch {
      print("Fetch Error (Customers):  \(error)")
      }
      
      // Set the delegate to this view controller
      fetchedResultsController.delegate = self
      
      // Delete all customers to ensure no duplicates when downloading new list
      deleteAllCustomers()
      
      // update core data with items that were deleted
      CoreDataStackManager.sharedInstance().saveContext()
      
      // download new customer list
      downloadCustomerInformation()
    
    }


  
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

  // populate table rows with menu titles and icons
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var cell = tableView.dequeueReusableCellWithIdentifier("MenuItem") as UITableViewCell!
    
    if cell == nil {
      cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MenuItem")
    }
    
    // set label text and icon image
    if indexPath.row == 0 {
      
      cell.textLabel!.text = "Daily Checklist"
      cell.detailTextLabel!.text  = "Complete the Daily Visitation form."
      
      let image = UIImage(named:"checklist")
      cell.imageView!.image = image
      
    } else if indexPath.row == 1 {
      
      cell.textLabel!.text = "Request Maintenance"
      cell.detailTextLabel!.text  = "Is something broken?  Send us a service request."
      
      let image = UIImage(named:"wrench")
      cell.imageView!.image = image
      
    } else if indexPath.row == 2 {
      
      cell.textLabel!.text = "Customer Locations"
      cell.detailTextLabel!.text  = "View a map of our locations"
      
      let image = UIImage(named:"map")
      cell.imageView!.image = image
      
    } else if indexPath.row == 3 {
      
      cell.textLabel!.text = "Phone Book"
      cell.detailTextLabel!.text  = "Contact a co-worker or our management team."
      
      let image = UIImage(named:"people")
      cell.imageView!.image = image
      
    } else if indexPath.row == 4 {
      
      cell.textLabel!.text = "Message Board"
      cell.detailTextLabel!.text  = "View messages from HR."
      
      let image = UIImage(named:"reminder")
      cell.imageView!.image = image
      
    } else if indexPath.row == 5 {
      
      cell.textLabel!.text = "Logout"
      cell.detailTextLabel!.text  = "Exit the application."
      
      let image = UIImage(named:"logout")
      cell.imageView!.image = image
    }
    
    return cell!
  }
  

  // determine which row selected and then open browser session to display user's url
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    // do something
    if indexPath.row == 0 {
      // transtion to "Daily Checklist"
      self.performSegueWithIdentifier("UpcomingFeatures", sender: nil)
      
    } else if indexPath.row == 1 {
      // transtion to "Request Maintenance" view
      self.performSegueWithIdentifier("ShowMaintenance", sender: nil)

      
    } else if indexPath.row == 2 {
      // transtion to "Customer Locations" view
        self.performSegueWithIdentifier("ShowLocations", sender: nil)
      
    } else if indexPath.row == 3 {
      // transtion to "Phone Book"
      self.performSegueWithIdentifier("UpcomingFeatures", sender: nil)
      
    } else if indexPath.row == 4 {
      // transtion to "Message Board"
      self.performSegueWithIdentifier("UpcomingFeatures", sender: nil)
      
    } else if indexPath.row == 5 {
      // Logout
      // Remove user ID from NSDefaults
      self.saveUserInfo("", firstName: "", lastName: "")
      
      // Dismiss view controller and returning to login controller
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
  }

  
  // MARK: Custom Functions
  
  // save user's information to Documents Directory
  func saveUserInfo(userName: String, firstName: String, lastName: String) {
    
    // Save the user's User ID, first name and last name for future use.
    let dictionary = [
      "userName" : userName,
      "firstName" : firstName,
      "lastName" : lastName
    ]
    
    // Archive the dictionary into the filePath
    NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    
    print("User Data Filepath:  \(filePath)")
    print("User Data Saved:  \(dictionary)")
  }
  
  
  
  
  // function to delete all customers and reload data to ensure any new info is always added; may change SQL query later to only download new customers
  func deleteAllCustomers() {
    
    // delete all pictures in core data one by one
    for customer in fetchedResultsController.fetchedObjects as! [Customer] {
      sharedContext.deleteObject(customer)
    }
    
  }
  
  // Function to download current customer data; called each time app is loaded
  func downloadCustomerInformation() {
    
    PMClient.sharedInstance.retreivePoolInformation {success, parsedResult, errorCode, errorText in
    
      // if successful.......
      if (success == true) && (errorCode == nil) {
        
        // Save the context
        self.saveContext()
        
      }else {
        // Print error and display alert to the user
        print("Error:  \(errorCode!) - \(errorText!)")
        
        dispatch_async(dispatch_get_main_queue()) {
          
          // Set alert title and text
          let alertTitle = errorCode
          let alertMessage = errorText
          
          // Display alert message
          self.displayAlertMessage(alertTitle!, message: alertMessage!)
        }
      }
    }
  }
  
  
  // Generic function to display alert messages to users
  func displayAlertMessage(title: String, message: String) {
    dispatch_async(dispatch_get_main_queue(), {    let controller = UIAlertController()
      
      // set alert title and message using data passed to function
      controller.title = title
      controller.message = message
      
      let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil)
      
      // add buttons and display message
      controller.addAction(okAction)
      self.presentViewController(controller, animated: true, completion: nil)
    })
  }


}
