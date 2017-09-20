//
//  StyleAnnotationView.swift
//  streetClean
//
//  Created by JIAN LI on 8/6/17.
//  Copyright © 2017 JIAN LI. All rights reserved.
//

import UIKit
import Mapbox
import Animo

enum EventType{
  case onEntry
  case onExit
  case onNull
}

class StyleAnnotationView: MGLAnnotationView{
  
  var markerLayer: CALayer!
  var haloLayer: CALayer!
  var bgLayer: CALayer!
  var radius: CGFloat!
  var color: UIColor!
  
  var eventType: EventType!
  
  var n = 0
  
  init(reuseIdentifier: String, size: CGFloat, color: UIColor) {
    super.init(reuseIdentifier: reuseIdentifier)
    eventType = .onNull
    radius = size
    self.color = color
    setupLayer()
    setupBgLayer()
    //setupMarkerLayer()
  }
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    //turnToDot(me: selected)
  }

  func setupLayer(){
    let rect = CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)
    layer.frame = rect
    layer.cornerRadius = radius
  }
  
  func setupBgLayer(){
    let bgcolor = UIColor(red: 77.0/255.0, green: 100.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    bgLayer = CALayer()
    bgLayer.frame = self.layer.frame
    bgLayer.cornerRadius = self.layer.cornerRadius
    bgLayer.backgroundColor = bgcolor.cgColor
    bgLayer.borderWidth = radius*0.3
    bgLayer.borderColor = color.cgColor
    layer.insertSublayer(bgLayer, at: 0)
  }
  func turnToDot(me: Bool){
    
    let bgAnimation0 = CABasicAnimation(keyPath: "borderWidth")
    bgAnimation0.duration = 0.3
    bgLayer.borderWidth = me ? radius : radius*0.3
    bgLayer.add(bgAnimation0, forKey: "borderWidth")
    
    let originSize = layer.bounds
    let big = CGRect(x: 0, y: 0, width: originSize.width, height: originSize.height)
    let small = CGRect(x: 0, y: 0, width: originSize.width/2, height: originSize.height/2)
    let bgAnimation1 = CABasicAnimation(keyPath: "bounds")
    bgAnimation1.duration = 0.3
    bgLayer.bounds = me ? small : big
    bgLayer.add(bgAnimation1, forKey: "bounds")
 
    let bigR = big.size.width/2
    let smallR = small.size.width/2
    let bgAnimation2 = CABasicAnimation(keyPath: "cornerRadius")
    bgAnimation2.duration = 0.3
    bgLayer.cornerRadius = me ? smallR : bigR
    bgLayer.add(bgAnimation2, forKey: "cornerRadius")
    
    //使用插件
    let fadeout = Animo.fadeOut(duration: 0.3)
    let fadein = Animo.fadeIn(duration: 0.3)
    let markerAnimo = me ? fadeout : fadein
    _ = markerLayer.runAnimation(markerAnimo)

  }
  
  func expand(enter: Bool, enterRadius: CGFloat, existRadius: CGFloat){
    
    let borderWidth = enter ? 0 : radius*0.3
    
    let bgAnimation0 = CABasicAnimation(keyPath: "borderWidth")
    bgAnimation0.duration = 0.3
    bgLayer.borderWidth = borderWidth
    bgLayer.add(bgAnimation0, forKey: "borderWidth")
    
    let big = CGRect(x: 0, y: 0, width: enterRadius*2, height: enterRadius*2)
    let small = CGRect(x: 0, y: 0, width: existRadius*2, height: existRadius*2)
    let bgAnimation1 = CABasicAnimation(keyPath: "bounds")
    bgAnimation1.duration = 0.3
    layer.bounds = enter ? small : big
    bgLayer.bounds = layer.bounds
    layer.add(bgAnimation1, forKey: "bounds")
    
    let bigR = big.size.width/2
    let smallR = small.size.width/2
    let bgAnimation2 = CABasicAnimation(keyPath: "cornerRadius")
    bgAnimation2.duration = 0.3
    bgLayer.cornerRadius = enter ? smallR : bigR
    bgLayer.add(bgAnimation2, forKey: "cornerRadius")
    
    let transparency: Float = 0.4
    let opacity: Float = 1.0
    let bgAnimation3 = CABasicAnimation(keyPath: "opacity")
    bgAnimation3.duration = 0.3
    bgLayer.opacity = enter ? transparency : opacity
    bgLayer.add(bgAnimation3, forKey: "opacity")
    
    let fromColor = enter ? UIColor.cyan : UIColor.cyan
    let toColor = enter ? UIColor.red : UIColor.cyan
    let colorAni = Animo.keyPath("backgroundColor", from: fromColor, to: toColor, duration: 1, timingMode: .easeInOut)
    _ = bgLayer.runAnimation(colorAni)

  }
  
  func setupMarkerLayer(){
    let rect = CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)
    markerLayer = CALayer()
    markerLayer.frame = rect
    markerLayer.cornerRadius = radius
    markerLayer.backgroundColor = UIColor.white.cgColor
    layer.insertSublayer(markerLayer, at: 1)
    
    let maskLayer = CALayer()
    let ratio: CGFloat = 0.5
    let width = markerLayer.frame.width*ratio
    let height = markerLayer.frame.height*ratio
    let mid = markerLayer.bounds.midX - width/2.0
    let rect1 = CGRect(x: mid, y: mid, width: width, height: height)
    maskLayer.frame = rect1
    markerLayer.addSublayer(maskLayer)
    markerLayer.mask = maskLayer
    markerLayer.masksToBounds = true
  }
  
  func setupHaloLayer(){
    let rect = CGRect(x: 0, y: 0, width: 2 * radius, height: 2 * radius)
    haloLayer = CALayer()
    haloLayer.frame = rect
    haloLayer.cornerRadius = radius
    haloLayer.opacity = 0
    layer.insertSublayer(haloLayer, below: markerLayer)
  }

  func animateHaloLayer(){
    haloLayer.opacity = 1
    let animation =
      Animo.group(
        Animo.scale(from: 0.0, by: 0.0, to: 2.0, duration: 0.8, timingMode: .easeInSine),
        Animo.fadeOut(duration: 0.8)
    )
    _ = haloLayer.runAnimation(animation)
  }
  
  func composition(){
    //以add模式添加到背景上
    //各种滤镜见：
    //CILuminosityBlendMode, CIOverlayBlendMode, CIScreenBlendMode, CISoftLightBlendMode,
    //CITemperatureAndTint，CIColorBlendMode
    
    if let compositingFilter = CIFilter(name: "CIAdditionCompositing") {
      let filter = [compositingFilter]
      layer.backgroundFilters = filter
    }
  }
}

extension MGLAnnotationView {
  func resizeMarkerLayer(){
    let markerAnimo = Animo.fadeOut(duration: 0.4)
    let bgAnimo = Animo.scale(by: 0.2, duration: 0.4, timingMode: .easeInOut)
    let sublayers = layer.sublayers
    if let marker = sublayers?[1] {
      _ = marker.runAnimation(markerAnimo)
    }
    if let bg = sublayers?[0]{
      _ = bg.runAnimation(bgAnimo)
    }
  }
  
  func halo(enter: Bool, size: CGFloat){
    if let sublayers = layer.sublayers{
      let bgLayer = sublayers[0]
      let scaleAnimo = Animo.scale(by: enter ? 4 : 1,
                                duration: 0.4,
                                timingMode: .easeInOut)
      
      let borderAnimo = Animo.keyPath("borderWidth",
                                      from: enter ? (size/2)*0.3 : 0,
                                      to: enter ? 0: (size/2)*0.3,
                                      duration: 0.4,
                                      timingMode: .easeInOut)
      
      let color1 = UIColor.cyan
      let color2 = UIColor(red: 229.0/255.0, green: 169.0/255.0, blue: 64.0/255.0, alpha: 1.0)
      let colorAnimo = Animo.keyPath("backgroundColor",
                                      from: enter ? color1 : color2,
                                      to: enter ? color2: color1,
                                      duration: 0.4,
                                      timingMode: .easeInOut)
      
      let opacityAnimo = Animo.keyPath("opacity",
                                       from: enter ? 1.0 : 0.5,
                                       to: enter ? 0.5: 1.0,
                                       duration: 0.4,
                                       timingMode: .easeInOut)
     
      _ = bgLayer.runAnimation(scaleAnimo)
      _ = bgLayer.runAnimation(borderAnimo)
      _ = bgLayer.runAnimation(colorAnimo)
      _ = bgLayer.runAnimation(opacityAnimo)
    }
  }
}
