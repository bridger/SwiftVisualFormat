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

        // |[redView][greenView][blueView]|
        
        self.view.addConstraints(layout(.Horizontal, |[redView.vf == greenView.vf] ))
        self.view.addConstraints(layout(.Horizontal, [blueView.vf == greenView.vf]| ))
        
        self.view.addConstraints(layout(.Vertical, |[redView.vf]| ))
        self.view.addConstraints(layout(.Vertical, |[greenView.vf]| ))
        self.view.addConstraints(layout(.Vertical, |[blueView.vf]| ))
        
        self.view.addConstraint( redView.al_trailing == greenView.al_leading )
        self.view.addConstraint( greenView.al_trailing == blueView.al_leading )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

