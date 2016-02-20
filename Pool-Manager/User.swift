//
//  User.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 2/1/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import Foundation

struct User {
  
  var userName = ""
  var isLockedOut: Bool = true
  var isApproved: Bool = false
  var firstName = ""
  var lastName = ""
  var street = ""
  var city = ""
  var state = ""
  var zip = ""
  var telephoneNumber = ""
  var wirelessNumber = ""
  var emailAddress = ""
  var status = ""
  
//  /* Construct a User struct from a dictionary */
  init(dictionary: [String : AnyObject]) {
    
    userName = dictionary["UserName"] as! String
    isLockedOut = dictionary["IsLockedOut"] as! Bool
    isApproved = dictionary["IsApproved"] as! Bool
    firstName = dictionary["FirstName"] as! String
    lastName = dictionary["LastName"] as! String
    street = dictionary["Street"] as! String
    city = dictionary["City"] as! String
    state = dictionary["State"] as! String
    zip = dictionary["Zip"] as! String
    telephoneNumber = dictionary["TelephoneNumber"] as! String
    wirelessNumber = dictionary["WirelessNumber"] as! String
    emailAddress = dictionary["EmailAddress"] as! String
    status = dictionary["Status"] as! String
    
  }
}