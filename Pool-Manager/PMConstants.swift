//
//  PMConstants.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 1/30/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import UIKit
import Foundation

extension PMClient {
  
  // Constants
  struct Constants {
    
    // Acme API Methods
    static let parseValidateUserURL : String = "https://acmetestapi.azurewebsites.net/api/user?id="
//    static let parseValidateUserURL : String = "https://acmetestapi.azurewebsites.net/api/employee?id="  // migrate to after API complete

    
    // Acme API Constants
    static let acmeAPIKey : String = "KOAEEWLJGESFSYWEWFL"
    
    //  Parse API Methods
    static let parseGetCustomerLocationsURL : String = "https://api.parse.com/1/classes/Customer"
    static let parsePostMaintenanceRequestURL : String = "https://api.parse.com/1/classes/MaintenanceRequest"
    
    // Parse Constants
    static let parseAppID : String = "HEQ5YBP0OFVj8wGT4FTbVWJ5RIR6aJRqoLbbKpMc"
    static let parseRestAPIKey : String = "9RmeXfJYT8pyZPJRKNsiALQYg6MDEad9H9yqIs5e"
    
    // Location Constants
    static let corporateName = "SwimMetro Management, Inc."
    static let corporateAddress = "310 Turner Road, North Chesterfield, VA 23225"
    
  }
}