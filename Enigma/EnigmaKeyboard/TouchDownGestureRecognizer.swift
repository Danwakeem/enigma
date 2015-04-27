//
//  TouchDownGestureRecognizer.swift
//  Enigma
//
//  Created by Dan jarvis on 4/26/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//


class TouchDownGestureRecognizer: UIGestureRecognizer {
    
    override init(target: AnyObject, action: Selector) {
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        if self.state == .Possible {
            self.state = .Began
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        self.state = .Failed
    }
    
    override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        self.state = .Failed
    }
}


