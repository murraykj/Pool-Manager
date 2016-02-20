//
//  Customer
//  Pool-Manager
//
//  Created by Kevin Murray on 1/13/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//


import Foundation
import CoreData


// Make Customer available to Objective-C code
@objc(Customer)


// MARK:  Class Definition

// Make Customer a subclass of NSManagedObject
class Customer : NSManagedObject {
  
  // Map column names used by Parse to your app
  struct Keys {
    static let CustName = "custName"
    static let AddressStreet = "Address_Street"
    static let AddressCityStateZip = "Address_City"
    static let CustPhone = "CustPhoneNumber"
  }
  
  
  // We are promoting these from simple properties to Core Data attributes
  @NSManaged var custName: String
  @NSManaged var addressStreet: String
  @NSManaged var addressCityStateZip: String
  @NSManaged var custPhone: String

  
  // Include this standard Core Data init method.
  override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }
  
  
  // Implement the two argument Init method. The method has two goals:
  //  - insert the new Person into a Core Data Managed Object Context
  //  - initialze the Person's properties from a dictionary
  
  init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
    
    // Get the entity associated with the "Customer" type.  This is an object that contains the information from the Model.xcdatamodeld file.
    let entity =  NSEntityDescription.entityForName("Customer", inManagedObjectContext: context)!
    
    // Call the init method that we have inherited from NSManagedObject.  The Customer class is a subclass of NSManagedObject.
    // This inherited init method does the work of "inserting" our object into the context that was passed in as a parameter.
    super.init(entity: entity,insertIntoManagedObjectContext: context)
    
    // After the Core Data work has been taken care of we can init the properties from the dictionary
    custName = dictionary[Keys.CustName] as! String
    addressStreet = dictionary[Keys.AddressStreet] as! String
    addressCityStateZip = dictionary[Keys.AddressCityStateZip] as! String
    custPhone = dictionary[Keys.CustPhone] as! String
    
  }
  
  
  /* Helper: Given an array of dictionaries, convert them to an array of Student Information objects */
  static func customersFromResults(results: [[String : AnyObject]], context: NSManagedObjectContext) -> [Customer] {
    var customersInformation = [Customer]()
    
    for result in results {
      customersInformation.append(Customer(dictionary: result, context: context))
    }
    
    return customersInformation
  }
  
  
  
  var title: String {
    return custName
  }
  
  var subtitle: String {
    return (addressStreet + ", " + addressCityStateZip)
  }
  
}
