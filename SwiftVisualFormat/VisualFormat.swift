//
//  VisualFormat.swift
//  SwiftVisualFormat
//
//  Created by Bridger Maxwell on 8/1/14.
//  Copyright (c) 2014 Bridger Maxwell. All rights reserved.
//

import UIKit


// layoutHorizontal(|[imageView.vf >= 20.vf]-(>=0.vf!20.vf)-[imageView.vf]-50.vf-|)

protocol ViewContainingToken {
    var firstView: UIView { get }
    var lastView: UIView { get }
}

struct ViewToken: ViewContainingToken {
    let view: ALView
    var firstView: UIView {
    get {
        return self.view
    }
    }
    var lastView: UIView {
    get {
        return self.view
    }
    }
}
struct ConstantToken {
    let constant: CGFloat
    let priority: Float
}

protocol ContraintAble {
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint];
}


struct SizeConstantConstraintToken {
    let view: ViewToken
    let size: ConstantToken
    let relation: NSLayoutRelation
}

struct SizeRelationConstraintToken: ContraintAble {
    let view: ViewToken
    let relatedView: ViewToken
    let relation: NSLayoutRelation
    
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
            relatedBy: .Equal,
            toItem: relatedView, attribute: attribute,
            multiplier: 1.0, constant: 0) ]
    }
}

struct SuperviewConstraintToken: ContraintAble {
    let viewContainer: ViewContainingToken
    let space: ConstantToken
    let isLeading: Bool
    
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint] {
        var view: UIView!
        if (self.isLeading) {
            view = self.viewContainer.firstView
        } else {
            view = self.viewContainer.lastView
        }
        let constant = self.space.constant
        let priority = self.space.priority
        
        if let superview = view.superview {
            var constraint: NSLayoutConstraint!
            
            if (axis == .Horizontal) {
                if (self.isLeading) {
                    constraint = NSLayoutConstraint(
                        item: superview, attribute: .Leading,
                        relatedBy: .Equal,
                        toItem: view, attribute: .Leading,
                        multiplier: 1.0, constant: constant)
                } else {
                    constraint = NSLayoutConstraint(
                        item: view, attribute: .Trailing,
                        relatedBy: .Equal,
                        toItem: superview, attribute: .Trailing,
                        multiplier: 1.0, constant: constant)
                }
            } else {
                if (self.isLeading) {
                    constraint = NSLayoutConstraint(
                        item: superview, attribute: .Top,
                        relatedBy: .Equal,
                        toItem: view, attribute: .Top,
                        multiplier: 1.0, constant: constant)
                    
                    constraint = superview.al_top == view.al_top + constant
                } else {
                    constraint = NSLayoutConstraint(
                        item: view, attribute: .Bottom,
                        relatedBy: .Equal,
                        toItem: superview, attribute: .Bottom,
                        multiplier: 1.0, constant: constant)
                }
            }
            
            constraint.priority = priority
            return [constraint]
        }
        NSException(name: NSInvalidArgumentException, reason: "You tried to create a constraint to \(view)'s superview, but it has no superview yet!", userInfo: nil).raise()
        return [dummyConstraint] // To appease the compiler, which doesn't realize this branch dies
    }
}


let RequiredPriority: Float = 1000 // For some reason, the linker can't find UILayoutPriorityRequired

operator prefix | {}
@prefix func | (tokenArray: [ViewToken]) -> SuperviewConstraintToken {
    // |[view]
    return SuperviewConstraintToken(viewContainer: tokenArray[0], space: ConstantToken(constant: 0, priority: RequiredPriority), isLeading: true)
}

operator postfix | {}
@postfix func | (tokenArray: [ViewToken]) -> SuperviewConstraintToken {
    // [view]|
    return SuperviewConstraintToken(viewContainer: tokenArray[0], space: ConstantToken(constant: 0, priority: RequiredPriority), isLeading: false)
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


func layout(axis: UILayoutConstraintAxis, constraintAble: ContraintAble) -> [NSLayoutConstraint] {
    return constraintAble.toConstraints(axis)
}

func layout(axis: UILayoutConstraintAxis, constraintAble: [ContraintAble]) -> [NSLayoutConstraint] {
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
        return ConstantToken(constant: self, priority: RequiredPriority)
    }
    }
}

extension NSInteger {
    var vf: ConstantToken {
    get {
        return ConstantToken(constant: CGFloat(self), priority: RequiredPriority)
    }
    }
}


