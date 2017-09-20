//
//  Location.swift
//  GeofencingTest
//
//  Created by JIAN LI on 9/19/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import CoreLocation
import Mapbox

class Location: NSObject {
  
  var latitude = Double()
  var longitude = Double()
  var timestamp = Date()
  
  override init(){
    super.init()
  }
  
  init(coord: CLLocationCoordinate2D){
    
  }
  
  init(userLocation: MGLUserLocation){
    latitude = userLocation.coordinate.latitude
    longitude = userLocation.coordinate.longitude
  }

}
