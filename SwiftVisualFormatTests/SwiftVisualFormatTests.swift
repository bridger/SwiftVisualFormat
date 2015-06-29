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
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView = containerView
        
        let redView = UIView()
        redView.backgroundColor = UIColor.redColor()
        redView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(redView)
        self.redView = redView
        
        let greenView = UIView()
        greenView.backgroundColor = UIColor.greenColor()
        greenView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(greenView)
        self.greenView = greenView
        
        let blueView = UIView()
        blueView.backgroundColor = UIColor.blueColor()
        blueView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.addSubview(blueView)
        self.blueView = blueView
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func compareConstraints(visualFormatString: String, checkedConstraints: [NSLayoutConstraint]) {
        let views = ["redView" : redView, "blueView" : blueView, "greenView" : greenView]
        let referenceConstraints = NSLayoutConstraint.constraintsWithVisualFormat(visualFormatString, options: [], metrics: nil, views: views) as [NSLayoutConstraint]
        
        XCTAssertEqual(checkedConstraints.count, referenceConstraints.count, "The correct amount of constraints wasn't created")
        
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
    
    func compareHorizontalAndVerticalConstraints(formatString: String, constraintAble: [ConstraintAble]) {
        compareConstraints("H:" + formatString, checkedConstraints: constraints(.Horizontal, constraintAble: constraintAble))
        compareConstraints("V:" + formatString, checkedConstraints: constraints(.Vertical, constraintAble: constraintAble))
    }
    
    func testSuperviewSpace() {
        compareHorizontalAndVerticalConstraints("|-5-[redView]", constraintAble: |-5-[redView] )
        compareHorizontalAndVerticalConstraints("|[redView]", constraintAble: |[redView] )
        compareHorizontalAndVerticalConstraints("[redView]-5-|", constraintAble: [redView]-5-| )
        compareHorizontalAndVerticalConstraints("[redView]|", constraintAble: [redView]| )
        
        compareHorizontalAndVerticalConstraints("|[redView]|", constraintAble: |[redView]| )
        compareHorizontalAndVerticalConstraints("|-5-[redView]|", constraintAble: |-5-[redView]| )
        compareHorizontalAndVerticalConstraints("|[redView]-5-|", constraintAble: |[redView]-5-| )
    }
    
    func testWidthConstraints() {
        compareHorizontalAndVerticalConstraints("[redView(==greenView)]", constraintAble: [redView==greenView] )
        compareHorizontalAndVerticalConstraints("[redView(>=greenView)]", constraintAble: [redView>=greenView] )
        compareHorizontalAndVerticalConstraints("[redView(<=greenView)]", constraintAble: [redView<=greenView] )
    }
    
    func testSpaceConstraints() {
        compareHorizontalAndVerticalConstraints("[redView]-5-[greenView]", constraintAble: [redView]-5-[greenView] )
        compareHorizontalAndVerticalConstraints("[redView]-0-[greenView]", constraintAble: [redView]-0-[greenView] )
    }
    
    func testCombinedConstraints() {
        compareHorizontalAndVerticalConstraints("|-5-[redView(>=blueView)]-10-[greenView]-15-[blueView]-20-|", constraintAble: |-5-[redView >= blueView]-10-[greenView]-15-[blueView]-20-| )
        compareHorizontalAndVerticalConstraints("|[redView(>=blueView)]-10-[greenView]-15-[blueView]-20-|", constraintAble: |[redView >= blueView]-10-[greenView]-15-[blueView]-20-| )
        compareHorizontalAndVerticalConstraints("|-5-[redView(>=blueView)]-10-[greenView]-15-[blueView]|", constraintAble: |-5-[redView >= blueView]-10-[greenView]-15-[blueView]| )

    }
}
