//
//  AddEncryptionButton.swift
//  Enigma
//
//  Created by Dan jarvis on 6/24/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class AddEncryptionButton: UIButton {
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    var scale:CGFloat = 1.95
    var bgColor = UIColor(red: 0.172, green: 0.6, blue: 0.827, alpha: 1)
    
    override func drawRect(rect: CGRect) {
        // Drawing code
        var fillColor = bgColor
        var path = UIBezierPath(ovalInRect: CGRectMake(0, 0, 100 / scale, 100 / scale))
        fillColor.setFill()
        path.fill()
        
        var fillColor1 = UIColor(red: 0.968, green: 0.968, blue: 0.968, alpha: 1)
        var path1 = UIBezierPath(rect: CGRectMake(49 / scale, 32 / scale, 3 / scale, 35 / scale))
        fillColor1.setFill()
        path1.fill()
        
        var fillColor2 = UIColor(red: 0.968, green: 0.968, blue: 0.968, alpha: 1)
        var path2 = UIBezierPath()
        path2.moveToPoint(CGPointMake(33 / scale,50 / scale))
        path2.addLineToPoint(CGPointMake(33 / scale,47 / scale))
        path2.addLineToPoint(CGPointMake(68 / scale,47 / scale))
        path2.addLineToPoint(CGPointMake(68 / scale,50 / scale))
        path2.addLineToPoint(CGPointMake(33 / scale,50 / scale))
        fillColor2.setFill()
        path2.fill()
    }
}
