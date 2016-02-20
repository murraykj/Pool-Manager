//
//  LoginViewController.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 1/31/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import UIKit

class LoginViewViewController: UIViewController, UITextFieldDelegate {

  // MARK: User Controls
  
  @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var textboxUserID: UITextField!
  @IBOutlet weak var textboxPassword: UITextField!
  
  @IBAction func btnLogin(sender: AnyObject) {
    
    // display activity indicator
    loginActivityIndicator.hidden = false
    loginActivityIndicator.startAnimating()
    
    // assign values from the user ID and Password to variables
    let userID = textboxUserID.text
    let password = textboxPassword.text
  
    // check for missing user ID
    if (userID == ""){
      dispatch_async(dispatch_get_main_queue()) {
        
        // Display alert message
        self.displayAlertMessage("Missing User ID", message: "Please enter a user ID")
      }
    // check for missing password
    } else if (password == "") {
        dispatch_async(dispatch_get_main_queue()) {
          
          // Display alert message
          self.displayAlertMessage("Missing Password", message: "Please enter a password")
      }
    } else {
        // retrieve user data
        PMClient.sharedInstance.retreiveUserInformation(userID!, password: password!){
          userData, errorCode, errorText in
      
        // if user ID and password are validated, complete login process
        if (userData?.status == "User Authenticated") && (errorCode == nil) {
          self.saveUserInfo((userData?.userName)!, firstName: (userData?.firstName)!, lastName: (userData?.lastName)!)
 
          // turn off activity indicator
          self.loginActivityIndicator.stopAnimating()
          self.loginActivityIndicator.hidden = true
          
          self.completeLogin()
          
        } else if (userData?.status == "Incorrect ID or Invalid Password") && (errorCode == nil) {
          dispatch_async(dispatch_get_main_queue()) {
            
            // Display alert message
            self.displayAlertMessage("Login Error", message: "You have entered an incorrect user ID or an invalid password")
          }
          
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
  }
  
  
  // Function to open SwimMetro web session to allow creation of new account
  @IBAction func btnNewAccount(sender: AnyObject) {
    UIApplication.sharedApplication().openURL(NSURL(string:"https://swimmetro.com/prd/CreateUser.aspx")!)
  }
  
  // #MARK: - Core Data Components
  
  // A convenience property to set the filepath to store the map region
  var filePath : String {
    let manager = NSFileManager.defaultManager()
    let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as NSURL!
    return url.URLByAppendingPathComponent("userInfoArchive").path!
  }
  
  
  // MARK: Standard ViewController Functions
  override func viewDidLoad() {
      super.viewDidLoad()

    // set the delegate for the text fields
    self.textboxUserID.delegate = self
    self.textboxPassword.delegate = self
    
    // used for debugging to validate data stored in profile
    retreiveUserInfo()

  }

  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Subscribe to keyboard notifications to allow the view to raise when necessary
    self.subscribeToKeyboardNotifications()
    
    // clear out user name and password fileds when redisplaying view; important for logout process
    self.textboxUserID.text = ""
    self.textboxPassword.text = ""
    
    // turn off activity indicator
    self.loginActivityIndicator.stopAnimating()
    self.loginActivityIndicator.hidden = true
  }
  
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Unsubscribe from notifications
    self.unsubscribeFromKeyboardNotifications()
  }
  
  
  // MARK: Custom Functions
  //Generic function to display alert messages to users
  func displayAlertMessage(title: String, message: String) {
    dispatch_async(dispatch_get_main_queue(), {    let controller = UIAlertController()
      
      // turn off activity indicator
      self.loginActivityIndicator.stopAnimating()
      self.loginActivityIndicator.hidden = true
      
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
  
  
  // save user's information
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
  
  
  func retreiveUserInfo() {
    
    // retreive the user's profile data from the documents directory; used in this view for debugging
    if let userInfoDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
      
      let userName = userInfoDictionary["userName"] as! String
      let firstName = userInfoDictionary["firstName"] as! String
      let lastName = userInfoDictionary["lastName"] as! String
      
      print("User Info Retreived:  userName: \(userName), firstName: \(firstName), lastName: \(lastName)")
      
    }
  }
  
  
  // Function to display tabbed view after successful login
  func completeLogin() {
    
    // used here for debugging to ensure data was save.
    retreiveUserInfo()
    
    dispatch_async(dispatch_get_main_queue(), {
      
      // display next view controller - tableview controller (main menu)
      let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MenuTableNavigationView")
      self.presentViewController(controller!, animated: true, completion: nil)
    })
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
    if textboxUserID.isFirstResponder() {
      self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
    if textboxPassword.isFirstResponder() {
      self.view.frame.origin.y -= getKeyboardHeight(notification)
    }
  }
  
  // when keyboard is hidden adjust view down
  func keyboardWillHide(notification: NSNotification) {
    if textboxUserID.isFirstResponder() {
      self.view.frame.origin.y = 0
    }
    if textboxPassword.isFirstResponder() {
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
