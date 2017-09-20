//
//  MapVC+Interface.swift
//  GeofencingTest
//
//  Created by JIAN LI on 9/19/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import Foundation
import Mapbox

extension MapViewController {
  
  func initElements(){
    initMapView()
    initBtn()
    initData()
  }
  
  func initData(){
    let coord = userStartPosition
    let loc = Location(coord: coord)
    run.addToLocation(location: loc)
  }

  func initBtn(){
    let y2y: CGFloat = 28.0
    
    let rect1 = CGRect(x: gSize.width-58, y:36 , width: 50, height: 20)
    let startRunBtn = UIButton(frame: rect1)
    startRunBtn.backgroundColor = UIColor.cyan
    startRunBtn.addTarget(self, action: #selector(startRunTapped(_:)), for: .touchUpInside)
    view.addSubview(startRunBtn)
    
    let rect2 = CGRect(x: gSize.width-58, y:36+y2y , width: 50, height: 20)
    let stopRunBtn = UIButton(frame: rect2)
    stopRunBtn.backgroundColor = UIColor.red
    stopRunBtn.addTarget(self, action: #selector(stopRunTapped(_:)), for: .touchUpInside)
    view.addSubview(stopRunBtn)
    
    let rect3 = CGRect(x: gSize.width-58, y:36+(y2y*2) , width: 50, height: 20)
    let binBtn = UIButton(frame: rect3)
    binBtn.backgroundColor = UIColor.white
    binBtn.addTarget(self, action: #selector(binTapped(_:)), for: .touchUpInside)
    view.addSubview(binBtn)
    
    let rect4 = CGRect(x: gSize.width-58, y:36+(y2y*3) , width: 50, height: 20)
    let basBtn = UIButton(frame: rect4)
    basBtn.backgroundColor = UIColor.gray
    basBtn.addTarget(self, action: #selector(baseTapped(_:)), for: .touchUpInside)
    view.addSubview(basBtn)
  }
  
  func startRunTapped(_ sender: UIButton){
    print("start run")
  }
  func stopRunTapped(_ sender: UIButton){
    print("stop run")
  }
  
  func binTapped(_ sender: UIButton){
    activeType = .infrastructure
  }
  func baseTapped(_ sender: UIButton){
    activeType = .base
  }
  
}
