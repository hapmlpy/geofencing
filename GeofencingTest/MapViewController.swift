//
//  ViewController.swift
//  GeofencingTest
//
//  Created by JIAN LI on 9/18/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class MapViewController: UIViewController {
  
  var dataModel = DataModel()
  
  let gSize = UIScreen.main.bounds.size
  
  var run = Run()
  
  var locationManager = CLLocationManager()
  var seconds = 0
  var timer: Timer!
  var distance = Measurement(value: 0, unit: UnitLength.meters)
  var locationList: [CLLocation] = []
  
  var enterRegion: Bool!
  
  var userStartPosition = CLLocationCoordinate2DMake(39.926270, 116.395230)
  

  //map view自己用的数据
  var mapView: MGLMapView!
  var undeterminedNode: NodeAnnotioan?
  var activeType: NodeType = .null
  var pointAnnotations = [NodeAnnotioan]()
  var gNode = [Node]()
  var nodeID = 0
  var bases = [NodeAnnotioan]()
  var isHasBase = false
  var currentBounds: MGLCoordinateBounds?
  var geoCircleSource: MGLShapeSource!
  var geoAnnotations = [NodeAnnotioan]()
  var enterRegionId: String!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initElements()
    initLocationManager()
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  


}



