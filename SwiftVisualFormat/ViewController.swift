//
//  ViewController.swift
//  SwiftVisualFormat
//
//  Created by Bridger Maxwell on 8/1/14.
//  Copyright (c) 2014 Bridger Maxwell. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let redView = UIView()
        redView.backgroundColor = UIColor.redColor()
        redView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(redView)
        
        let greenView = UIView()
        greenView.backgroundColor = UIColor.greenColor()
        greenView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(greenView)
        
        let blueView = UIView()
        blueView.backgroundColor = UIColor.blueColor()
        blueView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(blueView)
                
        self.view.addConstraints(horizontalConstraints( |-5-[redView]-0-[greenView]-0-[blueView]-5-| ))
        
        self.view.addConstraints(horizontalConstraints( [redView == greenView] ))
        self.view.addConstraints(horizontalConstraints( [blueView == greenView] ))
        
        self.view.addConstraints(verticalConstraints( |-5-[redView]-5-| ))
        self.view.addConstraints(verticalConstraints( |-5-[greenView]-5-| ))
        self.view.addConstraints(verticalConstraints( |-5-[blueView]-5-| ))
    }
}

