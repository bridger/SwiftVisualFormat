//
//  VisualFormat.swift
//  SwiftVisualFormat
//
//  Created by Bridger Maxwell on 8/1/14.
//  Copyright (c) 2014 Bridger Maxwell. All rights reserved.
//

#if os(OSX)
    import AppKit
    public typealias ALView = NSView
    #elseif os(iOS)
    import UIKit
    public typealias ALView = UIView
#endif

// layoutHorizontal(|[imageView.al >= 20.al]-(>=0.al!20.al)-[imageView.al]-50.al-|)

@objc protocol ConstraintAble {
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint];
}

func constraints(axis: UILayoutConstraintAxis, constraintAble: [ConstraintAble]) -> [NSLayoutConstraint] {
    return constraintAble[0].toConstraints(axis)
}

func horizontalConstraints(constraintAble: [ConstraintAble]) -> [NSLayoutConstraint] {
    return constraints(.Horizontal, constraintAble)
}

func verticalConstraints(constraintAble: [ConstraintAble]) -> [NSLayoutConstraint] {
    return constraints(.Vertical, constraintAble)
}


@objc protocol ViewContainingToken {
    var firstView: ALView? { get }
    var lastView: ALView? { get }
}

protocol ConstantToken {
    var ALConstant: CGFloat { get }
}

// This is half of a space constraint, [view]-space
class ViewAndSpaceToken {
    let view: ViewContainingToken
    let space: ConstantToken
    let relation: NSLayoutRelation
    init(view: ViewContainingToken, space: ConstantToken, relation: NSLayoutRelation) {
        self.view = view
        self.space = space
        self.relation = relation
    }
}

// This is half of a space constraint, |-5
class LeadingSuperviewAndSpaceToken {
    let space: ConstantToken
    let relation: NSLayoutRelation
    init(space: ConstantToken, relation: NSLayoutRelation) {
        self.space = space
        self.relation = relation
    }
}
// This is half of a space constraint, 5-|
class TrailingSuperviewAndSpaceToken {
    let space: ConstantToken
    init(space: ConstantToken) {
        self.space = space
    }
}

// [view]-5-[view2]
class SpacedViewsConstraintToken: ConstraintAble, ViewContainingToken {
    let leadingView: ViewContainingToken
    let trailingView: ViewContainingToken
    let space: ConstantToken
    
    init(leadingView: ViewContainingToken, trailingView: ViewContainingToken, space: ConstantToken) {
        self.leadingView = leadingView
        self.trailingView = trailingView
        self.space = space
    }
    
    var firstView: UIView? {
    get {
        return self.leadingView.firstView
    }
    }
    var lastView: UIView? {
    get {
        return self.trailingView.lastView
    }
    }

    
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint] {
        if let leadingView = self.leadingView.lastView {
            if let trailingView = self.trailingView.firstView {
                let space = self.space.ALConstant
                
                var leadingAttribute: NSLayoutAttribute!
                var trailingAttribute: NSLayoutAttribute!
                if (axis == .Horizontal) {
                    leadingAttribute = .Leading
                    trailingAttribute = .Trailing
                } else {
                    leadingAttribute = .Top
                    trailingAttribute = .Bottom
                }
                
                var constraints = [NSLayoutConstraint(
                    item: trailingView, attribute: leadingAttribute,
                    relatedBy: .Equal,
                    toItem: leadingView, attribute: trailingAttribute,
                    multiplier: 1.0, constant: space)]
                
                if let leadingConstraint = self.leadingView as? ConstraintAble {
                    constraints += leadingConstraint.toConstraints(axis)
                }
                if let trailingConstraint = self.trailingView as? ConstraintAble {
                    constraints += trailingConstraint.toConstraints(axis)
                }

                return constraints
            }
        }
        
        NSException(name: NSInvalidArgumentException, reason: "This space constraint was between two view items that couldn't fit together. Weird?", userInfo: nil).raise()
        return [dummyConstraint] // To appease the compiler, which doesn't realize this branch dies
    }
}

// [view == 50]
class SizeConstantConstraintToken: ConstraintAble, ViewContainingToken {
    let view: ALView
    let size: ConstantToken
    let relation: NSLayoutRelation
    init(view: ALView, size: ConstantToken, relation: NSLayoutRelation) {
        self.view = view
        self.size = size
        self.relation = relation
    }
    
    var firstView: ALView? {
    get {
        return self.view.firstView
    }
    }
    var lastView: ALView? {
    get {
        return self.view.lastView
    }
    }
    
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint] {
        let constant = self.size.ALConstant
        
        var attribute: NSLayoutAttribute!
        if (axis == .Horizontal) {
            attribute = .Width
        } else {
            attribute = .Height
        }
        let constraint = NSLayoutConstraint(
            item: self.view, attribute: attribute,
            relatedBy: self.relation,
            toItem: nil, attribute: .NotAnAttribute,
            multiplier: 1.0, constant: constant)
        
        return [constraint]
    }
    
}

// [view == view2]
class SizeRelationConstraintToken: ConstraintAble, ViewContainingToken {
    let view: ALView
    let relatedView: ALView
    let relation: NSLayoutRelation
    init(view: ALView, relatedView: ALView, relation: NSLayoutRelation) {
        self.view = view
        self.relatedView = relatedView
        self.relation = relation
    }
    
    var firstView: ALView? {
    get {
        return self.view.firstView
    }
    }
    var lastView: ALView? {
    get {
        return self.view.lastView
    }
    }
    
    func toConstraints(axis: UILayoutConstraintAxis) -> [NSLayoutConstraint] {
        var attribute: NSLayoutAttribute!
        if (axis == .Horizontal) {
            attribute = .Width
        } else {
            attribute = .Height
        }
        return [ NSLayoutConstraint(
            item: self.view, attribute: attribute,
            relatedBy: self.relation,
            toItem: self.relatedView, attribute: attribute,
            multiplier: 1.0, constant: 0) ]
    }
}

// |-5-[view]
class LeadingSuperviewConstraintToken: ConstraintAble, ViewContainingToken {
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
            let constant = self.space.ALConstant
            
            if let superview = view.superview {
                var constraint: NSLayoutConstraint!
                
                if (axis == .Horizontal) {
                        constraint = NSLayoutConstraint(
                            item: view, attribute: .Leading,
                            relatedBy: .Equal,
                            toItem: superview, attribute: .Leading,
                            multiplier: 1.0, constant: constant)
                } else {
                        constraint = NSLayoutConstraint(
                            item: view, attribute: .Top,
                            relatedBy: .Equal,
                            toItem: superview, attribute: .Top,
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
        NSException(name: NSInvalidArgumentException, reason: "This superview bar | was before something that doesn't have a view. Weird?", userInfo: nil).raise()
        return [dummyConstraint] // To appease the compiler, which doesn't realize this branch dies
    }
    
    
}

// [view]-5-|
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
            let constant = self.space.ALConstant
            
            if let superview = view.superview {
                var constraint: NSLayoutConstraint!
                
                if (axis == .Horizontal) {
                    constraint = NSLayoutConstraint(
                        item: superview, attribute: .Trailing,
                        relatedBy: .Equal,
                        toItem: view, attribute: .Trailing,
                        multiplier: 1.0, constant: constant)
                } else {
                    constraint = NSLayoutConstraint(
                        item: superview, attribute: .Bottom,
                        relatedBy: .Equal,
                        toItem: view, attribute: .Bottom,
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

let RequiredPriority: Float = 1000 // For some reason, the linker can't find UILayoutPriorityRequired. Not sure what I am doing wrong

operator prefix | {}
@prefix func | (tokenArray: [ViewContainingToken]) -> [LeadingSuperviewConstraintToken] {
    // |[view]
    return [LeadingSuperviewConstraintToken(viewContainer: tokenArray[0], space: 0)]
}

operator postfix | {}
@postfix func | (tokenArray: [ViewContainingToken]) -> [TrailingSuperviewConstraintToken] {
    // [view]|
    return [TrailingSuperviewConstraintToken(viewContainer: tokenArray[0], space: 0)]
}

operator infix >= {}
@infix func >= (left: ALView, right: ConstantToken) -> SizeConstantConstraintToken {
    // [view >= 50]
    return SizeConstantConstraintToken(view: left, size: right, relation: .GreaterThanOrEqual)
}
@infix func >= (left: ALView, right: ALView) -> SizeRelationConstraintToken {
    // [view >= view2]
    return SizeRelationConstraintToken(view: left, relatedView: right, relation: .GreaterThanOrEqual)
}

operator infix <= {}
@infix func <= (left: ALView, right: ConstantToken) -> SizeConstantConstraintToken {
    // [view <= 50]
    return SizeConstantConstraintToken(view: left, size: right, relation: .LessThanOrEqual)
}
@infix func <= (left: ALView, right: ALView) -> SizeRelationConstraintToken {
    // [view <= view2]
    return SizeRelationConstraintToken(view: left, relatedView: right, relation: .LessThanOrEqual)
}

operator infix == {}
@infix func == (left: ALView, right: ConstantToken) -> SizeConstantConstraintToken {
    // [view == 50]
    return SizeConstantConstraintToken(view: left, size: right, relation: .Equal)
}
@infix func == (left: ALView, right: ALView) -> SizeRelationConstraintToken {
    // [view == view2]
    return SizeRelationConstraintToken(view: left, relatedView: right, relation: .Equal)
}

operator infix - {}
@infix func - (left: [ViewContainingToken], right: ConstantToken) -> ViewAndSpaceToken {
    // [view]-5
    return ViewAndSpaceToken(view: left[0], space: right, relation: .Equal)
}

@infix func - (left: ViewAndSpaceToken, right: [ViewContainingToken]) -> [SpacedViewsConstraintToken] {
    // [view]-5-[view2]
    return [SpacedViewsConstraintToken(leadingView: left.view, trailingView: right[0], space: left.space)]
}

@infix func - (left: [ViewContainingToken], right: TrailingSuperviewAndSpaceToken) -> [TrailingSuperviewConstraintToken] {
    // [view]-5-|
    return [TrailingSuperviewConstraintToken(viewContainer: left[0], space: right.space)]
}

@infix func - (left: LeadingSuperviewAndSpaceToken, right: [ViewContainingToken]) -> [LeadingSuperviewConstraintToken] {
    // |-5-[view]
    return [LeadingSuperviewConstraintToken(viewContainer: right[0], space: left.space)]
}

operator postfix -| {}
@postfix func -| (constant: ConstantToken) -> TrailingSuperviewAndSpaceToken {
    // 5-|
    return TrailingSuperviewAndSpaceToken(space: constant)
}

operator prefix |- {}
@prefix func |- (constant: ConstantToken) -> LeadingSuperviewAndSpaceToken {
    // |-5
    return LeadingSuperviewAndSpaceToken(space: constant, relation: .Equal)
}


let dummyConstraint = NSLayoutConstraint(item: nil, attribute: .NotAnAttribute, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)

extension ALView: ViewContainingToken {
    
    var firstView: ALView? {
    get {
        return self
    }
    }
    var lastView: ALView? {
    get {
        return self
    }
    }
}

extension CGFloat: ConstantToken {
    var ALConstant: CGFloat {
    get {
        return self
    }
    }
}

extension NSInteger: ConstantToken {
    var ALConstant: CGFloat {
    get {
        return CGFloat(self)
    }
    }
}

