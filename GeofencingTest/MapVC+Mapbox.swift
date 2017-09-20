//
//  MapVC+Mapbox.swift
//  GeofencingTest
//
//  Created by JIAN LI on 9/19/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Mapbox

extension MapViewController{
  
  func initMapView(){
    let styleURL = NSURL(string: "mapbox://styles/hapmlpy/cj5410a8n0uk92spb2hufzx7k")
    mapView = MGLMapView(frame: view.bounds, styleURL: styleURL as URL?)
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    mapView.setCenter(userStartPosition, zoomLevel: 14, animated: false)
    view.addSubview(mapView)
    mapView.delegate = self
    mapView.showsUserLocation = true
    mapView.setUserTrackingMode(.follow, animated: true)
  
  }
  
  func addGeoAnnotation(regionId: String){
    guard let annotaitonData = dataModel.pointAnnotations,
      annotaitonData.count > 0 else {
      return
    }
    
    for annotation in annotaitonData{
      let uid = "\(annotation.uid)"
      if uid == regionId {
        let targetAnno = NodeAnnotioan()
        targetAnno.uid = annotation.uid
        targetAnno.nodeType = annotation.nodeType
        targetAnno.coordinate = annotation.coordinate
        targetAnno.reuseIdentifier = "geo"
        targetAnno.level = annotation.level
        targetAnno.radius = annotation.radius
        mapView.addAnnotation(targetAnno)
        break
      }
    }

    
  }
  
  func removeGeoAnnotation(regionId: String){
    guard let annotaitonData = mapView.annotations,
      annotaitonData.count > 0 else {
        return
    }
    
    let ans = annotaitonData as! [NodeAnnotioan]
    
    for annotation in ans{
      let uid = "\(annotation.uid)"
      //判断是否删除除了uid一样，还要看identifier是不是geo
      if uid == regionId && annotation.reuseIdentifier == "geo"{
        mapView.removeAnnotation(annotation)
        break
      }
    }
    

  }
  
  func handleTap(_ gesture: UITapGestureRecognizer){
    let spot = gesture.location(in: mapView)
    let spotCoordinate = mapView.convert(spot, toCoordinateFrom: mapView)
    let node = Node(id: nodeID, location: spotCoordinate)
    gNode.append(node)
    //nodesToSource(nodes: gNode)
    circleToSource(nodes: gNode)
    
    let pointAnnotation = NodeAnnotioan(node: node)
    
    if activeType == .base{
      bases.append(pointAnnotation)
      if bases.count > 0 {
        isHasBase = true
        //saveBaseState()
      }else{
        isHasBase = false
        //saveBaseState()
      }
      pointAnnotation.reuseIdentifier = "base"
      pointAnnotation.reuseIdentifier = "base"
    }else{
      pointAnnotation.reuseIdentifier = "bin"
      pointAnnotation.reuseIdentifier = "bin"
    }
    //对当前annotation注册geofencing
    startMonitoring(geotification: pointAnnotation)
    dataModel.pointAnnotations?.append(pointAnnotation)
    mapView.addAnnotations(dataModel.pointAnnotations!)
    
    nodeID = nodeID + 1
  }
  
  //使用多边形来画，好处在于准确地标记地理范围。
  func circlePolygon(coordinate: CLLocationCoordinate2D, degreesBetweenPoints: Double, withMeterRadius: Double) -> MGLPolygonFeature{
    
    let numberOfPoints = floor(360/degreesBetweenPoints)
    let distRadians: Double = withMeterRadius / 6371000.0
    //earth radius in meters
    let centerLatRadians: Double = coordinate.latitude * Double.pi / 180
    let centerLonRadians: Double = coordinate.longitude * Double.pi / 180
    
    var coordinates = [CLLocationCoordinate2D]()
    //array to hold all the points
    for index in 0 ..< Int(numberOfPoints){
      let degrees: Double = Double(index) * Double(degreesBetweenPoints)
      let degreeRadians: Double = degrees * Double.pi / 180
      let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
      let pointLonRadians: Double = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
      let pointLat: Double = pointLatRadians * 180 / Double.pi
      let pointLon: Double = pointLonRadians * 180 / Double.pi
      let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
      coordinates.append(point)
    }
    let last = coordinates.first!
    coordinates.append(last)
    //let polygon = MGLPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
    let polygFeature = MGLPolygonFeature(coordinates: &coordinates, count: UInt(coordinates.count))
    return polygFeature
  }

  func addCircleFence(style: MGLStyle){
    //使用circel style layer 绘出geofence的外观
    let nodeSource = MGLShapeSource(identifier: "node", shape: nil, options: nil)
    style.addSource(nodeSource)
    geoCircleSource = nodeSource
    
    ////使用Node的方法，node本质上都是点
    let nodeLayer = MGLCircleStyleLayer(identifier: "node", source: nodeSource)
    nodeLayer.circleColor = MGLStyleValue<UIColor>(rawValue: UIColor.cyan)
    nodeLayer.circleOpacity = MGLStyleValue<NSNumber>(rawValue: 0.5)
    
    
    nodeLayer.circleRadius = MGLStyleValue(interpolationMode: .exponential,
                                           cameraStops: [12: MGLStyleValue(rawValue: 6),
                                                         22: MGLStyleValue(rawValue: 220)],
                                           options: [.defaultValue: 10])
    
    //使用实际的圆形多边形
    let circleLayer = MGLFillStyleLayer(identifier: "geofence", source: nodeSource)
    circleLayer.fillColor = MGLStyleValue<UIColor>(rawValue: UIColor.gray)
    circleLayer.fillOpacity = MGLStyleValue<NSNumber>(rawValue: 0.1)
    style.addLayer(circleLayer)
    
    
  }
  
  func circleToSource(nodes: [Node]){
    var geoCircles = [MGLPolygonFeature]()
    if nodes.count > 0 {
      for node in nodes {
        let coord = node.location
        let feature = circlePolygon(coordinate: coord, degreesBetweenPoints: 45, withMeterRadius: 500)
        if let tryLevel = node.level{
          let value = NSNumber(integerLiteral: tryLevel)
          feature.attributes = ["level" : value]
          geoCircles.append(feature)
        }else{
          print("<convert line to featre>: 错误：level值为空，无法转换为featrue属性")
          return
        }
      }
    }else{
      
    }
    let multi = MGLShapeCollectionFeature(shapes: geoCircles)
    geoCircleSource?.shape = multi
  }
  
  func nodesToSource(nodes: [Node]) {
    var features = [MGLPointFeature]()
    if nodes.count > 0 {
      for node in nodes {
        let coord = node.location
        let feature = MGLPointFeature()
        feature.coordinate = coord
        if let tryLevel = node.level{
          let value = NSNumber(integerLiteral: tryLevel)
          feature.attributes = ["level" : value]
          features.append(feature)
        }else{
          print("<convert line to featre>: 错误：level值为空，无法转换为featrue属性")
          return
        }
      }
    }else{
      print("there are no node in sence")
    }
    let multi = MGLShapeCollectionFeature(shapes: features)
    geoCircleSource?.shape = multi
    
  }

}

extension MapViewController: MGLMapViewDelegate{
  //callout annotation
  func mapView(_ mapView:MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool{
    return true
  }
  
  func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    //预先给circel style设定好参数
    addCircleFence(style: style)
    let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
      gesture.require(toFail: recognizer)
    }
    mapView.addGestureRecognizer(gesture)
  }
  // user position updating
  func mapViewDidStopLocatingUser(_ mapView: MGLMapView) {
    if let userLoc = mapView.userLocation{
      let location = Location(userLocation: userLoc)
      run.addToLocation(location: location)
    }
  }
  /*
  func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
    
    var lastLocation = CLLocation()
    if locationList.count == 0{
      lastLocation = (userLocation?.location)!
    }else{
      lastLocation = locationList.last!
    }
    let lastcoord: CLLocationCoordinate2D = lastLocation.coordinate
    
    if let newcoord = userLocation?.coordinate{
      let dots: [CLLocationCoordinate2D] = [newcoord, lastcoord]
      let lineSegment = MGLPolyline(coordinates: dots, count: 2)
      mapView.addAnnotation(lineSegment)
      
      let newLocation = CLLocation(latitude:newcoord.latitude, longitude: newcoord.longitude)
      locationList.append(newLocation)
      
      print("enter a region or not? :\(self.enterRegion)")
      
      
    }
  }
  */
  // draw annotaitonview
  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
    guard annotation is MGLPointAnnotation else {
      return nil
    }
    let nodeAnnotation = annotation as? NodeAnnotioan
    if nodeAnnotation?.willUseImage == true{
      return nil
    }
    
    let reuseIdentifier = nodeAnnotation?.reuseIdentifier
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier!)
    if annotationView == nil {
      //let level = Double((nodeAnnotation?.level)!)
      let color = UIColor.cyan
      
      //设置view
      annotationView = StyleAnnotationView(reuseIdentifier: reuseIdentifier!, size:10,color:color)
      
      if reuseIdentifier == "geo"{
        print("in annotation view, got this annotation, enter is \(self.enterRegion)")
        annotationView?.halo(enter: self.enterRegion, size: 10)
      }
    }
    return annotationView
  }
  
}
