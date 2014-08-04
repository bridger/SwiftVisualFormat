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
        
        
        self.view.addConstraints(layout(.Horizontal, |-5.vf-[redView.vf]-0.vf-[greenView.vf]-0.vf-[blueView.vf]-5.vf-| ))
        
        self.view.addConstraints(layout(.Horizontal, [redView.vf == greenView.vf] ))
        self.view.addConstraints(layout(.Horizontal, [blueView.vf == greenView.vf] ))
        
        self.view.addConstraints(layout(.Vertical, |-5.vf-[redView.vf]-5.vf-| ))
        self.view.addConstraints(layout(.Vertical, |-5.vf-[greenView.vf]-5.vf-| ))
        self.view.addConstraints(layout(.Vertical, |-5.vf-[blueView.vf]-5.vf-| ))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

