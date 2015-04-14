//
//  PopupKey.swift
//  Enigma
//
//  Created by Dan jarvis on 4/13/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class PopupKey: UIView {
    
    var label = UILabel(frame: CGRectMake(16, 7, 30, 30))
    var labelSize: CGFloat = 30
    
    var textColor: UIColor = UIColor.darkTextColor()
    var frameColor: UIColor = UIColor.whiteColor()
    
    var deviceScaler: CGFloat = 3.3
    var device: String!
    
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    init(){
        super.init(frame: CGRectMake(0, 0, 200, 500))
        label.text = "H"
        label.textColor = UIColor.darkTextColor()
        label.font = UIFont.systemFontOfSize(30)
        label.textAlignment = .Center
        self.addSubview(label)
        backgroundColor = UIColor.clearColor()
    }
    
    init(backgroundColor: UIColor, textColor: UIColor, device: String) {
        //iPhone 6+ -- self.deviceScaler = 2.8
        //iPhone 6+ -- label.font = UIFont.systemFontOfSize(40)
        //iPhone 6  -- self.deviceScaler = 3.3
        //iPhone 5  -- self.deviceScaler = 3.8
        //iPhone 4s -- self.deviceScaler = 3.9
        self.device = device
        switch device {
        case "iPhone6+":
            self.deviceScaler = 2.8
            self.labelSize = 40
        case "iPhone6":
            self.deviceScaler = 3.3
        case "iPhone5":
            self.deviceScaler = 3.8
        case "iPhone 4":
            self.deviceScaler = 3.9
        default:
            self.deviceScaler = 3.3
        }
        
        width = 184 / self.deviceScaler
        height = 321 / self.deviceScaler
        super.init(frame: CGRectMake(0, 0, width, height))
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSizeMake(0, 3)
        
        self.frameColor = backgroundColor
        self.textColor = textColor
        label.text = "H"
        label.textColor = UIColor.darkTextColor()
        label.font = UIFont.systemFontOfSize(self.labelSize)
        self.addSubview(label)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.constraintsForLabel()
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constraintsForLabel() {
        let x = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 4)
        let top = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 10)
        let height = NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.labelSize)
        let width = NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.labelSize)
        self.addConstraints([x,top,height,width])
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        self.label.textColor = self.textColor
        var fillColor = self.frameColor
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(39 / deviceScaler,309 / deviceScaler))
        path.addLineToPoint(CGPointMake(39 / deviceScaler,187 / deviceScaler))
        path.addCurveToPoint(CGPointMake(31 / deviceScaler,170 / deviceScaler), controlPoint1: CGPointMake(39 / deviceScaler,187 / deviceScaler), controlPoint2: CGPointMake(39 / deviceScaler,177 / deviceScaler))
        path.addCurveToPoint(CGPointMake(7 / deviceScaler,149 / deviceScaler), controlPoint1: CGPointMake(22 / deviceScaler,163 / deviceScaler), controlPoint2: CGPointMake(7 / deviceScaler,149 / deviceScaler))
        path.addCurveToPoint(CGPointMake(0 / deviceScaler,131 / deviceScaler), controlPoint1: CGPointMake(7 / deviceScaler,149 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,141 / deviceScaler))
        path.addCurveToPoint(CGPointMake(0 / deviceScaler,25 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,121 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,25 / deviceScaler))
        path.addCurveToPoint(CGPointMake(27 / deviceScaler,0 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,25 / deviceScaler), controlPoint2: CGPointMake(3 / deviceScaler,0 / deviceScaler))
        path.addCurveToPoint(CGPointMake(158 / deviceScaler,0 / deviceScaler), controlPoint1: CGPointMake(50 / deviceScaler,0 / deviceScaler), controlPoint2: CGPointMake(158 / deviceScaler,0 / deviceScaler))
        path.addCurveToPoint(CGPointMake(184 / deviceScaler,27 / deviceScaler), controlPoint1: CGPointMake(158 / deviceScaler,0 / deviceScaler), controlPoint2: CGPointMake(183 / deviceScaler,2 / deviceScaler))
        path.addCurveToPoint(CGPointMake(184 / deviceScaler,132 / deviceScaler), controlPoint1: CGPointMake(184 / deviceScaler,52 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,132 / deviceScaler))
        path.addCurveToPoint(CGPointMake(176 / deviceScaler,150 / deviceScaler), controlPoint1: CGPointMake(184 / deviceScaler,132 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,141 / deviceScaler))
        path.addCurveToPoint(CGPointMake(155 / deviceScaler,168 / deviceScaler), controlPoint1: CGPointMake(168 / deviceScaler,158 / deviceScaler), controlPoint2: CGPointMake(155 / deviceScaler,168 / deviceScaler))
        path.addCurveToPoint(CGPointMake(145 / deviceScaler,187 / deviceScaler), controlPoint1: CGPointMake(155 / deviceScaler,168 / deviceScaler), controlPoint2: CGPointMake(145 / deviceScaler,178 / deviceScaler))
        path.addCurveToPoint(CGPointMake(144 / deviceScaler,308 / deviceScaler), controlPoint1: CGPointMake(145 / deviceScaler,196 / deviceScaler), controlPoint2: CGPointMake(144 / deviceScaler,308 / deviceScaler))
        path.addCurveToPoint(CGPointMake(130 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(144 / deviceScaler,308 / deviceScaler), controlPoint2: CGPointMake(145 / deviceScaler,321 / deviceScaler))
        path.addCurveToPoint(CGPointMake(53 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(115 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(53 / deviceScaler,321 / deviceScaler))
        path.addCurveToPoint(CGPointMake(39 / deviceScaler,310 / deviceScaler), controlPoint1: CGPointMake(53 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(39 / deviceScaler,321 / deviceScaler))
        path.addCurveToPoint(CGPointMake(39 / deviceScaler,309 / deviceScaler), controlPoint1: CGPointMake(39 / deviceScaler,299 / deviceScaler), controlPoint2: CGPointMake(39 / deviceScaler,309 / deviceScaler))
        fillColor.setFill()
        path.fill()
    }
}
