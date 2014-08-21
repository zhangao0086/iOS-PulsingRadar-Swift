//
//  ViewController.swift
//  PulsingRadar-Swift
//
//  Created by ZhangAo on 14-7-26.
//  Copyright (c) 2014年 ZA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var radarView: PulsingRadarView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let radarSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width)
        radarView = PulsingRadarView(frame: CGRectMake(0,(self.view.bounds.size.height-radarSize.height)/2,
                                            radarSize.width,radarSize.height))
        self.view.addSubview(radarView)

        NSTimer.scheduledTimerWithTimeInterval(0.5, target: radarView, selector: Selector("addOrReplaceItem"), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("deallocated")
        
    }

}

