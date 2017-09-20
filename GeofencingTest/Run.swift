//
//  Run.swift
//  GeofencingTest
//
//  Created by JIAN LI on 9/19/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit

class Run: NSObject {
  
  var distance = Double()
  var duration = Int()
  var timestamp = Date()
  var locations = Array<Location>()
  
  override init() {
    super.init()
  }
  
  init(locations: [Location]){
    self.locations = locations
  }
  
  func addToLocation(location: Location){
    self.locations.append(location)
  }

}
