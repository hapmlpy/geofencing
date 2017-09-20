//
//  MapVC+LocationManager.swift
//  GeofencingTest
//
//  Created by JIAN LI on 9/19/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

extension MapViewController  {
  
  func initLocationManager(){
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.activityType = .fitness
    locationManager.distanceFilter = 10
  }
  
  func region(withGeotification geotification: NodeAnnotioan) -> CLCircularRegion{
    let center = geotification.coordinate
    let rawRadius: Double = 500.0
    let radius = min(rawRadius, locationManager.maximumRegionMonitoringDistance)
    let region = CLCircularRegion(center: center, radius: radius, identifier: "\(geotification.uid)")
    region.notifyOnEntry = true
    region.notifyOnExit = true
    
    print("添加region, id是 \(geotification.uid)")
    return region
  }


  func startMonitoring(geotification: NodeAnnotioan) {
//    if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
//      showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
//      return
//    }
//    if CLLocationManager.authorizationStatus() != .authorizedAlways {
//      showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
//    }
    let region = self.region(withGeotification: geotification)
    locationManager.startMonitoring(for: region)
    print("start monitoring for region id \(region.identifier)")
  }
  
  func stopMonitoring(geotification: NodeAnnotioan){
    for region in locationManager.monitoredRegions{
      guard let circularRegion = region as? CLCircularRegion,
      circularRegion.identifier == geotification.reuseIdentifier else {
        continue
      }
      locationManager.stopMonitoring(for: circularRegion)
    }
  }
  
  // MARK: - geofence事件反馈
  func handleEvent(forRegion region: CLRegion, enter: Bool){
    if enter == true {
      print(".......enter region id \(region.identifier)..........\n")
      addGeoAnnotation(regionId: region.identifier)
    }else{
      print(".......exist region id \(region.identifier)..........")
      removeGeoAnnotation(regionId: region.identifier)
    }
    self.enterRegion = enter
    self.enterRegionId = region.identifier
  }
}

extension MapViewController: CLLocationManagerDelegate{
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    mapView.showsUserLocation = (status == .authorizedAlways)
  }
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

  }
  // MARK: - 建立geofence实况(handling error，侦听和反映在app delegate里)
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager failed with the following error: \(error)")
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleEvent(forRegion: region, enter: true)
      
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleEvent(forRegion: region, enter: false)
    }
  }
  
}
