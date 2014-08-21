//
//  PulsingRadarView.swift
//  PulsingRadar-Swift
//
//  Created by ZhangAo on 14-7-26.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

import UIKit
import QuartzCore

class PRButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = 0
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            UIView.animateWithDuration(1, animations: {
                self.alpha = 1
            })
        }
    }
    
    override func removeFromSuperview() {
        UIView.beginAnimations("", context: nil)
        UIView.setAnimationDuration(1)
        self.alpha = 0
        UIView.setAnimationDidStopSelector(Selector("callSuperRemoveFromSuperview"))
        UIView.commitAnimations()
    }
    
    private func callSuperRemoveFromSuperview() {
        super.removeFromSuperview()
    }
}


class PulsingRadarView: UIView {
    
    let itemSize = CGSizeMake(44, 44)
    var items = NSMutableArray()
    weak var animationLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: Selector("resume"),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resume() {
        if let animationLayer = self.animationLayer {
            animationLayer.removeFromSuperlayer()
            self.setNeedsDisplay()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addOrReplaceItem() {
        let maxCount = 10
        
        var radarButton = PRButton(frame: CGRectMake(0, 0, itemSize.width, itemSize.height))
        radarButton.setImage(UIImage(named: "UK"), forState: UIControlState.Normal)
        
        do {
            var center = generateCenterPointInRadar()
            radarButton.center = CGPointMake(center.x, center.y)
        } while (itemFrameIntersectsInOtherItem(radarButton.frame))
        
        self.addSubview(radarButton)
        items.addObject(radarButton)
        
        if items.count > maxCount {
            var view = items.objectAtIndex(0) as UIView
            view.removeFromSuperview()
            items.removeObject(view)
        }
    }
    
    private func itemFrameIntersectsInOtherItem (frame: CGRect) -> Bool {
        for item in items {
            if CGRectIntersectsRect(item.frame, frame) {
                return true
            }
        }
        return false
    }
    
    private func generateCenterPointInRadar() -> CGPoint{
        var angle = Double(arc4random()) % 360
        var radius = Double(arc4random()) % (Double)((self.bounds.size.width - itemSize.width)/2)
        var x = cos(angle) * radius
        var y = sin(angle) * radius
        return CGPointMake(CGFloat(x) + self.bounds.size.width / 2, CGFloat(y) + self.bounds.size.height / 2)
    }
    
    override func drawRect(rect: CGRect) {
        UIColor.whiteColor().setFill()
        UIRectFill(rect)
        
        let pulsingCount = 6
        let animationDuration: Double = 4

        var animationLayer = CALayer()
        for var i = 0; i < pulsingCount; i++ {
            var pulsingLayer = CALayer()
            pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height)
            pulsingLayer.borderColor = UIColor.grayColor().CGColor
            pulsingLayer.borderWidth = 1
            pulsingLayer.cornerRadius = rect.size.height / 2
            
            var defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            
            var animationGroup = CAAnimationGroup()
            animationGroup.fillMode = kCAFillModeBackwards
            animationGroup.beginTime = CACurrentMediaTime() + Double(i) * animationDuration / Double(pulsingCount)
            animationGroup.duration = animationDuration
            animationGroup.repeatCount = HUGE
            animationGroup.timingFunction = defaultCurve
            
            var scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = Double(0)
            scaleAnimation.toValue = Double(1.5)
            
            var opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnimation.values = [Double(1),Double(0.7),Double(0)]
            opacityAnimation.keyTimes = [Double(0),Double(0.5),Double(1)]
            
            animationGroup.animations = [scaleAnimation,opacityAnimation]
            
            pulsingLayer.addAnimation(animationGroup, forKey: "pulsing")
            animationLayer.addSublayer(pulsingLayer)
        }
        self.layer.addSublayer(animationLayer)
        self.animationLayer = animationLayer
    }
}