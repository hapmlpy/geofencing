//
//  OverLay.swift
//  GeofencingTest
//
//  Created by JIAN LI on 9/19/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Mapbox

class OverLay: NSObject, MGLOverlay {
  
  var coordinate = CLLocationCoordinate2D()
  var overlayBounds =  MGLCoordinateBounds()
  
  override init(){
    super.init()
  }
  
  init(coordinate: CLLocationCoordinate2D, bounds: MGLCoordinateBounds) {
    self.coordinate = coordinate
    overlayBounds = bounds
    
  }
  
  func intersects(_ overlayBounds: MGLCoordinateBounds) -> Bool {
    return true
  }

}
