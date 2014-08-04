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
                
        self.view.addConstraints(horizontalConstraints( |-5.al-[redView.al]-0.al-[greenView.al]-0.al-[blueView.al]-5.al-| ))
        
        self.view.addConstraints(horizontalConstraints( [redView.al == greenView.al] ))
        self.view.addConstraints(horizontalConstraints( [blueView.al == greenView.al] ))
        
        self.view.addConstraints(verticalConstraints( |-5.al-[redView.al]-5.al-| ))
        self.view.addConstraints(verticalConstraints( |-5.al-[greenView.al]-5.al-| ))
        self.view.addConstraints(verticalConstraints( |-5.al-[blueView.al]-5.al-| ))
    }
}

