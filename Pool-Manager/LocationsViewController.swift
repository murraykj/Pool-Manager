//
//  LocationsViewController.swift
//  Pool-Manager
//
//  Created by Kevin Murray on 2/10/16.
//  Copyright © 2016 Kevin Murray. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class LocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

  // MARK: User Controls
  @IBOutlet weak var mapView: MKMapView!
  
  
  
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
    
    // set mapView delegate
    mapView.delegate = self
    
    // Set the delegate to this view controller
    fetchedResultsController.delegate = self
    
    // Annotate Customer HQ on map and set map region
    annotateMapHQ(PMClient.Constants.corporateAddress)
    
    // invoke fetchedResultsController to retreive all customers
    do {
      try fetchedResultsController.performFetch()
    } catch {
      print("Fetch Error (Pictures):  \(error)")
    }
    
    // ...and then annotate customer locations on the map
    for customer in fetchedResultsController.fetchedObjects!{
      self.annotateMapCustomer(customer as! Customer)
    }
    
  }

  
  
  // MARK: Standard Map Functions

  // turn pin for pool locations green
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
      var pinView : MKAnnotationView! = nil
      print((annotation.title!)!)
    
      // if Not HQ, change color of Pin
      if let t = annotation.title where t != PMClient.Constants.corporateName {
        let ident = "greenPin"
        pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(ident)
        
        if pinView == nil {
          pinView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:ident)
          (pinView as! MKPinAnnotationView).pinTintColor = MKPinAnnotationView.greenPinColor()
          pinView.canShowCallout = true
        }
        pinView.annotation = annotation
      }
      return pinView
  }
  
  
  
  // MARK: Custom Map Functions

  // annotate corporate headquarters location on the map
  func annotateMapHQ(fullCorpAddress: String) -> Void {
    
    var placemarkLongitude = CLLocationDegrees()
    var placemarkLatitude = CLLocationDegrees()
    
    // create geocoder object
    let geocoder = CLGeocoder()
    
    print("Corporate Address:  \(fullCorpAddress)")
    
    // convert string address to geocode
    geocoder.geocodeAddressString(fullCorpAddress, completionHandler: {(placemarks, error) -> Void in
      
      if(error != nil)
      {
        print("Error", error)
      }
        
      else if let placemark = placemarks?[0]
      {
        
        if PMClient.Constants.corporateAddress == fullCorpAddress {
          
          // Get latitude and longitude coordinates for Corporate HQ
          placemarkLatitude = (placemark.location?.coordinate.latitude)!
          placemarkLongitude = (placemark.location?.coordinate.longitude)!
          
          // set map center on Corporate HQ
          let mapCenter = CLLocationCoordinate2D(latitude: placemarkLatitude, longitude: placemarkLongitude)
          let mapSpan = MKCoordinateSpanMake(0.70, 0.70)
          let region = MKCoordinateRegion(center:mapCenter,span: mapSpan)
          self.mapView.setRegion(region, animated: true)
          
          // set annotation label
          let annloc = CLLocationCoordinate2DMake(placemarkLatitude, placemarkLongitude)
          let ann = MKPointAnnotation()
          ann.coordinate = annloc
          ann.title = PMClient.Constants.corporateName
          ann.subtitle = PMClient.Constants.corporateAddress
          self.mapView.addAnnotation(ann)
        }
      }
    })
    
  }
  
  
  // annotate customer locations on the map
  func annotateMapCustomer(customer: Customer) -> Void {
    
    var placemarkLongitude = CLLocationDegrees()
    var placemarkLatitude = CLLocationDegrees()
    
    // create geocoder object
    let geocoder = CLGeocoder()
    
    // get complete address
    let fullAddress = customer.addressStreet + ", " + customer.addressCityStateZip
    print("Pool Address:  \(fullAddress)")
    
    // convert string address to geocode
    geocoder.geocodeAddressString(fullAddress, completionHandler: {(placemarks, error) -> Void in
      
      if(error != nil) {
        print("Error", error)
      }
      else if let placemark = placemarks?[0]
      {
          // Get latitude and longitude coordinates for customer address
          placemarkLatitude = (placemark.location?.coordinate.latitude)!
          placemarkLongitude = (placemark.location?.coordinate.longitude)!
          
          // set annotation label
          let annloc = CLLocationCoordinate2DMake(placemarkLatitude, placemarkLongitude)
          let ann = MKPointAnnotation()
          ann.coordinate = annloc
          ann.title = customer.custName
          ann.subtitle = fullAddress
          self.mapView.addAnnotation(ann)
      }
      
    })
  }

}
