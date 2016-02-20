//
//  MaintenanceViewController.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 2/10/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import UIKit
import CoreData

class MaintenanceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, NSFetchedResultsControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
  
  // MARK: User Controls
  
  @IBOutlet weak var pickerCustomerName: UIPickerView!
  @IBOutlet weak var textfieldWorkRequested: UITextView!
  @IBOutlet weak var textfieldSpecialInstructions: UITextView!
  @IBOutlet weak var segPriority: UISegmentedControl!
  @IBOutlet weak var textfieldContactName: UITextField!
  @IBOutlet weak var textfieldContactNumber: UITextField!
  
  @IBAction func btnCancel(sender: AnyObject) {
    
    // Dismiss view controller and return to menu controller
    self.dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  @IBAction func btnSubmit(sender: AnyObject) {
    
    // get pool name from picker control
    let row = pickerCustomerName.selectedRowInComponent(0)
    let indexPath = NSIndexPath(forRow: row, inSection: 0)
    let fetchedObject: AnyObject = self.fetchedResultsController.objectAtIndexPath(indexPath)
    
    // get values from other controls
    let reqPoolName = fetchedObject.valueForKey("custName") as! String
    let reqWorkRequested = textfieldWorkRequested.text
    let reqSpecialInstructions = textfieldSpecialInstructions.text
    let reqPriority = segPriority.titleForSegmentAtIndex(segPriority.selectedSegmentIndex)
    let reqContactName = textfieldContactName.text
    let reqContactNumber = textfieldContactNumber.text
    

    self.validateEntryFields(reqWorkRequested, reqContactName: reqContactName!, reqContactNumber: reqContactNumber!){
      success in
      
      if (success == true) {
        
        // retreive userID to submite with request.
        let submitterName = self.retreiveUserInfo()
        
    //    print (reqPoolName, reqWorkRequested, reqSpecialInstructions, reqPriority, reqContactName, reqContactNumber, submitterName)
        
        // call function to submit maintenance request
        PMClient.sharedInstance.postMaintenanceRequest(reqPoolName, reqWorkRequested: reqWorkRequested, reqSpecialInstructions: reqSpecialInstructions, reqPriority: reqPriority!, reqContactName: reqContactName!, reqContactNumber: reqContactNumber!, submitterName: submitterName!){
        success, errorCode, errorText in
        
          // if successful, display message and return user to menu
          if (success == true) && (errorCode == nil) {

            // if request submitted succssfully, Display message and return user to menu
            dispatch_async(dispatch_get_main_queue()) {
            
              // Set alert title and text
              let alertTitle = "Success!"
              let alertMessage = "Your maintenance request has been submitted."
              
              // Display alert message
              self.displayAlertMessageAndDismiss(alertTitle, message: alertMessage)
            }      
          }else {
            // Print error and display alert to the user
            print("Error:  \(errorCode!) - \(errorText!)")
            
            // Display alert and return user to the request form
            
            dispatch_async(dispatch_get_main_queue()) {
              
              // Set alert title and text
              let alertTitle = errorCode
              let alertMessage = errorText
               // Display alert message
              self.displayAlertMessageAndCancel(alertTitle!, alertMessage: alertMessage!)
             
            }

          }
          
        }  
        
      }
      
    }

  }
  
  
  
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
    
    // set the delegate for the text fields
    textfieldContactName.delegate = self
    textfieldContactNumber.delegate = self
    textfieldSpecialInstructions.delegate = self
    
    // round edges of tet fields
    pickerCustomerName.layer.cornerRadius = 10.0
    textfieldWorkRequested.layer.cornerRadius = 10.0
    textfieldSpecialInstructions.layer.cornerRadius = 10.0
    
    // invoke fetchedResultsController to retreive all customers
    do {
      try fetchedResultsController.performFetch()
    } catch {
      print("Fetch Error (Customers):  \(error)")
    }
    
    // Set the delegate to this view controller
    fetchedResultsController.delegate = self
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Subscribe to keyboard notifications to allow the view to raise when necessary
    self.subscribeToKeyboardNotifications()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Unsubscribe from notifications
    self.unsubscribeFromKeyboardNotifications()
  }
  
  
  
  // MARK: - Picker view methods
  
  // data source methods - number of components in picker
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  // data source methods - number of items in picker
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
    let sectionInfo = self.fetchedResultsController.sections![component]
    
    return sectionInfo.numberOfObjects
    }

  // set text of item in picker control
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
    let indexPath = NSIndexPath(forRow: row, inSection: 0)
    let fetchedObject: AnyObject = self.fetchedResultsController.objectAtIndexPath(indexPath)
//    print(fetchedObject.valueForKey("custName"))
    let poolName: AnyObject? = fetchedObject.valueForKey("custName")
    
    return poolName as? String
  }

  
  // #MARK: - Custom Functions
  
  // function to check user input
  func validateEntryFields(reqWorkRequested: String, reqContactName: String, reqContactNumber: String, completionHandler: (success: Bool) -> Void) {
    
    var status: Bool = true
    
    // Set title of alert message (same for all)
    let alertTitle = "Entry Error"
    
    if reqWorkRequested.isEmpty {
      // if work request details are missing, display message and return user to menu
      dispatch_async(dispatch_get_main_queue()) {

        // set text of alert message
        let alertMessage = "Please complete the Work Requested section."
        // Display alert message
        self.displayAlertMessageAndCancel(alertTitle, alertMessage: alertMessage)
        
      }
      // set status code
      status = false
      
    } else if reqContactName.isEmpty {
      // if work request details are missing, display message and return user to menu
      dispatch_async(dispatch_get_main_queue()) {
        
        // set text of alert message
        let alertMessage = "Please provide a contact name."
        // Display alert message
        self.displayAlertMessageAndCancel(alertTitle, alertMessage: alertMessage)
        
      }
      // set status code
      status = false
      
    } else if reqContactNumber.isEmpty {
      // if work request details are missing, display message and return user to menu
      dispatch_async(dispatch_get_main_queue()) {
        
        // set text of alert message
        let alertMessage = "Please provide a contact phone number."
        // Display alert message
        self.displayAlertMessageAndCancel(alertTitle, alertMessage: alertMessage)
        
      }
      // set status code
      status = false
    }
    
    // set status code
    completionHandler(success: status)
  }
  
    
  //function to display alert messages to users and then dismiss current viewcontroller
  func displayAlertMessageAndDismiss(title: String, message: String) {
    dispatch_async(dispatch_get_main_queue(), {
      
      let controller = UIAlertController()
      
      // set alert title and message using data passed to function
      controller.title = title
      controller.message = message
      
      // set action buttons for alert message
      let okAction = UIAlertAction (title: "ok", style: UIAlertActionStyle.Default) {
        action in self.dismissViewControllerAnimated(true, completion: nil)
      }
      
      // add buttons and display message
      controller.addAction(okAction)
      self.presentViewController(controller, animated: true, completion: nil)
    })
  }
  
  
  //Generic function to display alert messages to users and return to current view
  func displayAlertMessageAndCancel(alertTitle: String, alertMessage: String) {
    dispatch_async(dispatch_get_main_queue(), {
      
      let controller = UIAlertController()
      
      // set alert title and message using data passed to function
      controller.title = alertTitle
      controller.message = alertMessage
      
      // set action buttons for alert message
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
      
      // add buttons and display message
      controller.addAction(okAction)
    
      self.presentViewController(controller, animated: true, completion: nil)
    })
  }

  
  // retrieve user info from stored settings
  func retreiveUserInfo() -> String? {
    
    var submitterName: String = ""
    
    // retrieve the user's profile data from the documents directory
    if let userInfoDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
      
      // retreive user details
      let firstName = userInfoDictionary["firstName"] as! String
      let lastName = userInfoDictionary["lastName"] as! String
      let userID = userInfoDictionary["userName"] as! String
      
      // build user info string
      submitterName  = firstName + " " + lastName + " (" + userID + ")"
//      print("Submitter Info:  \(submitterName)")
      
    }
    return submitterName
  }
  

  
  // MARK: Keyboard Related Functions
  // reseign keyboard when user presses return
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true;
  }
  
  // Manage notifications from Keyboard
  // subcribe to keyboard functions
  func subscribeToKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
  }
  
  // unsubcribe to keyboard functions when done
  func unsubscribeFromKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name:
      UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name:
      UIKeyboardWillHideNotification, object: nil)
  }
  
  // when keyboard is displayed adjust view up
  func keyboardWillShow(notification: NSNotification) {
    if textfieldSpecialInstructions.isFirstResponder() {
      self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    if textfieldContactName.isFirstResponder() {
      self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    if textfieldContactNumber.isFirstResponder() {
      self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
  }
  
  // when keyboard is hidden adjust view down
  func keyboardWillHide(notification: NSNotification) {
    if textfieldSpecialInstructions.isFirstResponder() {
      self.view.frame.origin.y = 0
    }
    if textfieldContactName.isFirstResponder() {
      self.view.frame.origin.y = 0
    }
    if textfieldContactNumber.isFirstResponder() {
      self.view.frame.origin.y = 0
    }
  }
  
  // get height of keyboard to be used in functions above
  func getKeyboardHeight(notification: NSNotification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
    return keyboardSize.CGRectValue().height
  }

}


