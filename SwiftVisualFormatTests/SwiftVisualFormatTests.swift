//
//  SwiftVisualFormatTests.swift
//  SwiftVisualFormatTests
//
//  Created by Bridger Maxwell on 8/1/14.
//  Copyright (c) 2014 Bridger Maxwell. All rights reserved.
//

import UIKit
import XCTest

class SwiftVisualFormatTests: XCTestCase {
    
    var containerView: UIView!
    var redView: UIView!
    var greenView: UIView!
    var blueView: UIView!
    
    override func setUp() {
        super.setUp()
        
        let containerView = UIView()
        containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView = containerView
        
        let redView = UIView()
        redView.backgroundColor = UIColor.redColor()
        redView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.addSubview(redView)
        self.redView = redView
        
        let greenView = UIView()
        greenView.backgroundColor = UIColor.greenColor()
        greenView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.addSubview(greenView)
        self.greenView = greenView
        
        let blueView = UIView()
        blueView.backgroundColor = UIColor.blueColor()
        blueView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.containerView.addSubview(blueView)
        self.blueView = blueView
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func compareConstraints(visualFormatString: NSString, checkedConstraints: [NSLayoutConstraint]) {
        let views = ["redView" : redView, "blueView" : blueView, "greenView" : greenView]
        let referenceConstraints = NSLayoutConstraint.constraintsWithVisualFormat(visualFormatString, options: nil, metrics: nil, views: views) as [NSLayoutConstraint]
        
        XCTAssertEqual(countElements(checkedConstraints), countElements(referenceConstraints), "The correct amount of constraints wasn't created")
        
        for constraint in referenceConstraints {
            
            var foundMatch = false
            for checkConstraint in checkedConstraints {
                if (constraint.firstItem === checkConstraint.firstItem &&
                    constraint.firstAttribute == checkConstraint.firstAttribute &&
                    constraint.relation == checkConstraint.relation &&
                    constraint.secondItem === checkConstraint.secondItem &&
                    constraint.secondAttribute == checkConstraint.secondAttribute &&
                    constraint.multiplier == checkConstraint.multiplier &&
                    constraint.constant == checkConstraint.constant &&
                    constraint.priority == checkConstraint.priority) {
                        
                        foundMatch = true
                        break;
                }
            }
            
            XCTAssert(foundMatch, "The reference constraint \( constraint ) was not found in the created constraints: \(checkedConstraints)")
        }
    }
    
    func compareHorizontalAndVerticalConstraints(formatString: NSString, constraintAble: [ConstraintAble]) {
        compareConstraints("H:" + formatString, checkedConstraints: constraints(.Horizontal, constraintAble))
        compareConstraints("V:" + formatString, checkedConstraints: constraints(.Vertical, constraintAble))
    }
    
    func testSuperviewSpace() {
        compareHorizontalAndVerticalConstraints("|-5-[redView]", constraintAble: |-5.al-[redView.al] )
        compareHorizontalAndVerticalConstraints("|[redView]", constraintAble: |[redView.al] )
        compareHorizontalAndVerticalConstraints("[redView]-5-|", constraintAble: [redView.al]-5.al-| )
        compareHorizontalAndVerticalConstraints("[redView]|", constraintAble: [redView.al]| )
        
        compareHorizontalAndVerticalConstraints("|[redView]|", constraintAble: |[redView.al]| )
        compareHorizontalAndVerticalConstraints("|-5-[redView]|", constraintAble: |-5.al-[redView.al]| )
        compareHorizontalAndVerticalConstraints("|[redView]-5-|", constraintAble: |[redView.al]-5.al-| )
    }
    
    func testWidthConstraints() {
        compareHorizontalAndVerticalConstraints("[redView(==greenView)]", constraintAble: [redView.al==greenView.al] )
        compareHorizontalAndVerticalConstraints("[redView(>=greenView)]", constraintAble: [redView.al>=greenView.al] )
        compareHorizontalAndVerticalConstraints("[redView(<=greenView)]", constraintAble: [redView.al<=greenView.al] )
    }
    
    func testSpaceConstraints() {
        compareHorizontalAndVerticalConstraints("[redView]-5-[greenView]", constraintAble: [redView.al]-5.al-[greenView.al] )
        compareHorizontalAndVerticalConstraints("[redView]-0-[greenView]", constraintAble: [redView.al]-0.al-[greenView.al] )
    }
    
    func testCombinedConstraints() {
        compareHorizontalAndVerticalConstraints("|-5-[redView(>=blueView)]-10-[greenView]-15-[blueView]-20-|", constraintAble: |-5.al-[redView.al >= blueView.al]-10.al-[greenView.al]-15.al-[blueView.al]-20.al-| )
        compareHorizontalAndVerticalConstraints("|[redView(>=blueView)]-10-[greenView]-15-[blueView]-20-|", constraintAble: |[redView.al >= blueView.al]-10.al-[greenView.al]-15.al-[blueView.al]-20.al-| )
        compareHorizontalAndVerticalConstraints("|-5-[redView(>=blueView)]-10-[greenView]-15-[blueView]|", constraintAble: |-5.al-[redView.al >= blueView.al]-10.al-[greenView.al]-15.al-[blueView.al]| )

    }
}
