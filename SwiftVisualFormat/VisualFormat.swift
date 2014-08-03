//
//  VisualFormat.swift
//  SwiftVisualFormat
//
//  Created by Bridger Maxwell on 8/1/14.
//  Copyright (c) 2014 Bridger Maxwell. All rights reserved.
//

import UIKit


// layoutHorizontal(|[imageView.vf >= 20.vf]-(>=0.vf!20.vf)-[imageView.vf]-50.vf-|)


@objc protocol ViewContainingToken {
    var firstView: UIView? { get }
    var lastView: UIView? { get }
}

// This is either a token that directly is a view, or is a more complex token that is a composition of tokens, like [view]-space-[view]
class ViewToken: ViewContainingToken {
    let view: ALView
    init(view: ALView) {
        self.view = view
    }
    
    var firstView: UIView? {
    get {
        return self.view
    }
    }
    var lastView: UIView? {
    get {
        return self.view
    }
    }
}

class ConstantToken {
    let constant: CGFloat
    init(constant: CGFloat) {
        self.constant = constant
    }
}

@objc protocol ConstraintAble {
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint];
}


class SizeConstantConstraintToken: ConstraintAble, ViewContainingToken {
    let view: ViewToken
    let size: ConstantToken
    let relation: NSLayoutRelation
    init(view: ViewToken, size: ConstantToken, relation: NSLayoutRelation) {
        self.view = view
        self.size = size
        self.relation = relation
    }
    
    var firstView: UIView? {
    get {
        return self.view.view
    }
    }
    var lastView: UIView? {
    get {
        return self.view.view
    }
    }
    
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint] {
        let view = self.view.view;
        let constant = self.size.constant
        let relation = self.relation
        
        var attribute: NSLayoutAttribute!
        if (axis == .Horizontal) {
            attribute = .Width
        } else {
            attribute = .Height
        }
        let constraint = NSLayoutConstraint(
            item: view, attribute: attribute,
            relatedBy: self.relation,
            toItem: nil, attribute: .NotAnAttribute,
            multiplier: 1.0, constant: constant)
        
        return [constraint]
    }
    
}

class SizeRelationConstraintToken: ConstraintAble, ViewContainingToken {
    let view: ViewToken
    let relatedView: ViewToken
    let relation: NSLayoutRelation
    init(view: ViewToken, relatedView: ViewToken, relation: NSLayoutRelation) {
        self.view = view
        self.relatedView = relatedView
        self.relation = relation
    }
    
    var firstView: UIView? {
    get {
        return self.view.view
    }
    }
    var lastView: UIView? {
    get {
        return self.view.view
    }
    }
    
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint] {
        let view = self.view.view;
        let relatedView = self.relatedView.view
        let relation = self.relation
        
        var attribute: NSLayoutAttribute!
        if (axis == .Horizontal) {
            attribute = .Width
        } else {
            attribute = .Height
        }
        return [ NSLayoutConstraint(
            item: view, attribute: attribute,
            relatedBy: self.relation,
            toItem: relatedView, attribute: attribute,
            multiplier: 1.0, constant: 0) ]
    }
}

// |[view]
class LeadingSuperviewConstraint: ConstraintAble, ViewContainingToken {
    let viewContainer: ViewContainingToken
    let space: ConstantToken
    init(viewContainer: ViewContainingToken, space: ConstantToken) {
        self.viewContainer = viewContainer
        self.space = space
    }
    var firstView: UIView? {
    get {
        return nil // No one can bind to our first view, is the superview
    }
    }
    var lastView: UIView? {
    get {
        return self.viewContainer.lastView
    }
    }
    
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint] {
        if let view = self.viewContainer.firstView {
            let constant = self.space.constant
            
            if let superview = view.superview {
                var constraint: NSLayoutConstraint!
                
                if (axis == .Horizontal) {
                        constraint = NSLayoutConstraint(
                            item: superview, attribute: .Leading,
                            relatedBy: .Equal,
                            toItem: view, attribute: .Leading,
                            multiplier: 1.0, constant: constant)
                } else {
                        constraint = NSLayoutConstraint(
                            item: superview, attribute: .Top,
                            relatedBy: .Equal,
                            toItem: view, attribute: .Top,
                            multiplier: 1.0, constant: constant)
                        
                        constraint = superview.al_top == view.al_top + constant
                }
                
                if let otherConstraint = viewContainer as?  ConstraintAble {
                    return otherConstraint.toConstraints(axis) + [constraint]
                } else {
                    return [constraint]
                }
            }
            NSException(name: NSInvalidArgumentException, reason: "You tried to create a constraint to \(view)'s superview, but it has no superview yet!", userInfo: nil).raise()
        }
        NSException(name: NSInvalidArgumentException, reason: "This superview bar | was before something that doesn't have a view. Weird?", userInfo: nil).raise()
        return [dummyConstraint] // To appease the compiler, which doesn't realize this branch dies
    }
    
    
}

// [view]|
class TrailingSuperviewConstraintToken: ConstraintAble, ViewContainingToken {
    let viewContainer: ViewContainingToken
    let space: ConstantToken
    init(viewContainer: ViewContainingToken, space: ConstantToken) {
        self.viewContainer = viewContainer
        self.space = space
    }
    var firstView: UIView? {
    get {
        return self.viewContainer.firstView
    }
    }
    var lastView: UIView? {
    get {
        return nil // No one can bind to our last view, is the superview
    }
    }
    
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint] {
        if let view = self.viewContainer.lastView {
            let constant = self.space.constant
            
            if let superview = view.superview {
                var constraint: NSLayoutConstraint!
                
                if (axis == .Horizontal) {
                    constraint = NSLayoutConstraint(
                        item: view, attribute: .Trailing,
                        relatedBy: .Equal,
                        toItem: superview, attribute: .Trailing,
                        multiplier: 1.0, constant: constant)
                } else {
                    constraint = NSLayoutConstraint(
                        item: view, attribute: .Bottom,
                        relatedBy: .Equal,
                        toItem: superview, attribute: .Bottom,
                        multiplier: 1.0, constant: constant)
                }
                
                if let otherConstraint = viewContainer as?  ConstraintAble {
                    return otherConstraint.toConstraints(axis) + [constraint]
                } else {
                    return [constraint]
                }
            }
            NSException(name: NSInvalidArgumentException, reason: "You tried to create a constraint to \(view)'s superview, but it has no superview yet!", userInfo: nil).raise()
        }
        NSException(name: NSInvalidArgumentException, reason: "This superview bar | was after something that doesn't have a view. Weird?", userInfo: nil).raise()
        
        return [dummyConstraint] // To appease the compiler, which doesn't realize this branch dies
    }
}

let RequiredPriority: Float = 1000 // For some reason, the linker can't find UILayoutPriorityRequired

operator prefix | {}
@prefix func | (tokenArray: [ViewContainingToken]) -> [LeadingSuperviewConstraint] {
    // |[view]
    return [LeadingSuperviewConstraint(viewContainer: tokenArray[0], space: ConstantToken(constant: 0))]
}

operator postfix | {}
@postfix func | (tokenArray: [ViewContainingToken]) -> [TrailingSuperviewConstraintToken] {
    // [view]|
    return [TrailingSuperviewConstraintToken(viewContainer: tokenArray[0], space: ConstantToken(constant: 0))]
}

operator infix >= {}
@infix func >= (left: ViewToken, right: ConstantToken) -> SizeConstantConstraintToken {
    return SizeConstantConstraintToken(view: left, size: right, relation: .GreaterThanOrEqual)
}
@infix func >= (left: ViewToken, right: ViewToken) -> SizeRelationConstraintToken {
    return SizeRelationConstraintToken(view: left, relatedView: right, relation: .GreaterThanOrEqual)
}

operator infix <= {}
@infix func <= (left: ViewToken, right: ConstantToken) -> SizeConstantConstraintToken {
    return SizeConstantConstraintToken(view: left, size: right, relation: .LessThanOrEqual)
}
@infix func <= (left: ViewToken, right: ViewToken) -> SizeRelationConstraintToken {
    return SizeRelationConstraintToken(view: left, relatedView: right, relation: .LessThanOrEqual)
}

operator infix == {}
@infix func == (left: ViewToken, right: ConstantToken) -> SizeConstantConstraintToken {
    return SizeConstantConstraintToken(view: left, size: right, relation: .Equal)
}
@infix func == (left: ViewToken, right: ViewToken) -> SizeRelationConstraintToken {
    return SizeRelationConstraintToken(view: left, relatedView: right, relation: .Equal)
}

let dummyConstraint = NSLayoutConstraint(item: nil, attribute: .NotAnAttribute, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)

func layout(axis: UILayoutConstraintAxis, constraintAble: ConstraintAble) -> [NSLayoutConstraint] {
    return constraintAble.toConstraints(axis)
}

func layout(axis: UILayoutConstraintAxis, constraintAble: [ConstraintAble]) -> [NSLayoutConstraint] {
    return constraintAble[0].toConstraints(axis)
}

extension ALView {
    var vf: ViewToken {
    get {
        return ViewToken(view: self)
    }
    }
}

extension CGFloat {
    var vf: ConstantToken {
    get {
        return ConstantToken(constant: self)
    }
    }
}

extension NSInteger {
    var vf: ConstantToken {
    get {
        return ConstantToken(constant: CGFloat(self))
    }
    }
}

