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
    
    var duck = false
    var leftUpper = false
    var rightUpper = false
    var specialWideKey = false
    
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
        case "iPhone4":
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
        label.textAlignment = .Center
        self.addSubview(label)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.constraintsForLabel()
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constraintsForLabel() {
        let x = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 10)
        let height = NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.labelSize)
        let width = NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.labelSize)
        self.addConstraints([x,top,height,width])
    }
    
    func redoConstraintsForLabel(){
        self.removeConstraints(self.constraints())
        if self.duck {
            let x = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
            let top = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 28)
            let height = NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40)
            let width = NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40)
            self.addConstraints([x,top,height,width])
        } else if self.specialWideKey && self.device == "iPhone6+" {
            let x = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
            let top = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 36)
            let height = NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40)
            let width = NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40)
            self.addConstraints([x,top,height,width])
        } else if self.specialWideKey {
            //self.frame = CGRectMake(0, 0, self.width * 1.05, self.height)
            let x = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
            let top = NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 36)
            let height = NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            let width = NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
            self.addConstraints([x,top,height,width])
        } else {
            self.constraintsForLabel()
        }
    }
    
    func changeFrame(x: CGFloat, y: CGFloat) {
        self.frame = CGRectMake(x, y, self.width * 1.3, self.height * 1.3)
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        self.label.textColor = self.textColor
        var fillColor = self.frameColor
        if self.duck && self.leftUpper {
            var path = UIBezierPath()
            path.moveToPoint(CGPointMake(0 / deviceScaler,311 / deviceScaler))
            path.addLineToPoint(CGPointMake(0 / deviceScaler,86 / deviceScaler))
            path.addCurveToPoint(CGPointMake(25 / deviceScaler,65 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,86 / deviceScaler), controlPoint2: CGPointMake(2 / deviceScaler,65 / deviceScaler))
            path.addCurveToPoint(CGPointMake(158 / deviceScaler,65 / deviceScaler), controlPoint1: CGPointMake(47 / deviceScaler,65 / deviceScaler), controlPoint2: CGPointMake(158 / deviceScaler,65 / deviceScaler))
            path.addCurveToPoint(CGPointMake(186 / deviceScaler,85 / deviceScaler), controlPoint1: CGPointMake(158 / deviceScaler,65 / deviceScaler), controlPoint2: CGPointMake(186 / deviceScaler,67 / deviceScaler))
            path.addCurveToPoint(CGPointMake(186 / deviceScaler,170 / deviceScaler), controlPoint1: CGPointMake(186 / deviceScaler,102 / deviceScaler), controlPoint2: CGPointMake(186 / deviceScaler,170 / deviceScaler))
            path.addCurveToPoint(CGPointMake(182 / deviceScaler,181 / deviceScaler), controlPoint1: CGPointMake(186 / deviceScaler,170 / deviceScaler), controlPoint2: CGPointMake(186 / deviceScaler,177 / deviceScaler))
            path.addCurveToPoint(CGPointMake(117 / deviceScaler,232 / deviceScaler), controlPoint1: CGPointMake(178 / deviceScaler,185 / deviceScaler), controlPoint2: CGPointMake(117 / deviceScaler,232 / deviceScaler))
            path.addCurveToPoint(CGPointMake(108 / deviceScaler,248 / deviceScaler), controlPoint1: CGPointMake(117 / deviceScaler,232 / deviceScaler), controlPoint2: CGPointMake(108 / deviceScaler,237 / deviceScaler))
            path.addCurveToPoint(CGPointMake(108 / deviceScaler,311 / deviceScaler), controlPoint1: CGPointMake(108 / deviceScaler,259 / deviceScaler), controlPoint2: CGPointMake(108 / deviceScaler,311 / deviceScaler))
            path.addCurveToPoint(CGPointMake(95 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(108 / deviceScaler,311 / deviceScaler), controlPoint2: CGPointMake(106 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(12 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(83 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(12 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(0 / deviceScaler,312 / deviceScaler), controlPoint1: CGPointMake(12 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,320 / deviceScaler))
            path.addCurveToPoint(CGPointMake(0 / deviceScaler,311 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,305 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,311 / deviceScaler))
            fillColor.setFill()
            path.fill()
        } else if self.duck && self.rightUpper {
            var path = UIBezierPath()
            path.moveToPoint(CGPointMake(184 / deviceScaler,311 / deviceScaler))
            path.addLineToPoint(CGPointMake(184 / deviceScaler,86 / deviceScaler))
            path.addCurveToPoint(CGPointMake(159 / deviceScaler,65 / deviceScaler), controlPoint1: CGPointMake(184 / deviceScaler,86 / deviceScaler), controlPoint2: CGPointMake(182 / deviceScaler,65 / deviceScaler))
            path.addCurveToPoint(CGPointMake(27 / deviceScaler,65 / deviceScaler), controlPoint1: CGPointMake(137 / deviceScaler,65 / deviceScaler), controlPoint2: CGPointMake(27 / deviceScaler,65 / deviceScaler))
            path.addCurveToPoint(CGPointMake(0 / deviceScaler,85 / deviceScaler), controlPoint1: CGPointMake(27 / deviceScaler,65 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,67 / deviceScaler))
            path.addCurveToPoint(CGPointMake(0 / deviceScaler,170 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,102 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,170 / deviceScaler))
            path.addCurveToPoint(CGPointMake(3 / deviceScaler,181 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,170 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,177 / deviceScaler))
            path.addCurveToPoint(CGPointMake(68 / deviceScaler,232 / deviceScaler), controlPoint1: CGPointMake(8 / deviceScaler,185 / deviceScaler), controlPoint2: CGPointMake(68 / deviceScaler,232 / deviceScaler))
            path.addCurveToPoint(CGPointMake(77 / deviceScaler,248 / deviceScaler), controlPoint1: CGPointMake(68 / deviceScaler,232 / deviceScaler), controlPoint2: CGPointMake(77 / deviceScaler,237 / deviceScaler))
            path.addCurveToPoint(CGPointMake(77 / deviceScaler,311 / deviceScaler), controlPoint1: CGPointMake(77 / deviceScaler,259 / deviceScaler), controlPoint2: CGPointMake(77 / deviceScaler,311 / deviceScaler))
            path.addCurveToPoint(CGPointMake(90 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(77 / deviceScaler,311 / deviceScaler), controlPoint2: CGPointMake(78 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(172 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(101 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(172 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(184 / deviceScaler,312 / deviceScaler), controlPoint1: CGPointMake(172 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,320 / deviceScaler))
            path.addCurveToPoint(CGPointMake(184 / deviceScaler,311 / deviceScaler), controlPoint1: CGPointMake(184 / deviceScaler,305 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,311 / deviceScaler))
            fillColor.setFill()
            path.fill()
        } else if self.duck {
            var path = UIBezierPath()
            path.moveToPoint(CGPointMake(40 / deviceScaler,312 / deviceScaler))
            path.addLineToPoint(CGPointMake(40 / deviceScaler,214 / deviceScaler))
            path.addCurveToPoint(CGPointMake(31 / deviceScaler,200 / deviceScaler), controlPoint1: CGPointMake(40 / deviceScaler,214 / deviceScaler), controlPoint2: CGPointMake(40 / deviceScaler,206 / deviceScaler))
            path.addCurveToPoint(CGPointMake(8 / deviceScaler,184 / deviceScaler), controlPoint1: CGPointMake(23 / deviceScaler,195 / deviceScaler), controlPoint2: CGPointMake(8 / deviceScaler,184 / deviceScaler))
            path.addCurveToPoint(CGPointMake(1 / deviceScaler,170 / deviceScaler), controlPoint1: CGPointMake(8 / deviceScaler,184 / deviceScaler), controlPoint2: CGPointMake(1 / deviceScaler,177 / deviceScaler))
            path.addCurveToPoint(CGPointMake(1 / deviceScaler,84 / deviceScaler), controlPoint1: CGPointMake(1 / deviceScaler,162 / deviceScaler), controlPoint2: CGPointMake(1 / deviceScaler,84 / deviceScaler))
            path.addCurveToPoint(CGPointMake(27 / deviceScaler,65 / deviceScaler), controlPoint1: CGPointMake(1 / deviceScaler,84 / deviceScaler), controlPoint2: CGPointMake(4 / deviceScaler,65 / deviceScaler))
            path.addCurveToPoint(CGPointMake(158 / deviceScaler,65 / deviceScaler), controlPoint1: CGPointMake(51 / deviceScaler,64 / deviceScaler), controlPoint2: CGPointMake(158 / deviceScaler,65 / deviceScaler))
            path.addCurveToPoint(CGPointMake(184 / deviceScaler,86 / deviceScaler), controlPoint1: CGPointMake(158 / deviceScaler,65 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,66 / deviceScaler))
            path.addCurveToPoint(CGPointMake(184 / deviceScaler,86 / deviceScaler), controlPoint1: CGPointMake(158 / deviceScaler,65 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,66 / deviceScaler))
            path.addCurveToPoint(CGPointMake(184 / deviceScaler,170 / deviceScaler), controlPoint1: CGPointMake(184 / deviceScaler,106 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,170 / deviceScaler))
            path.addCurveToPoint(CGPointMake(176 / deviceScaler,184 / deviceScaler), controlPoint1: CGPointMake(184 / deviceScaler,170 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,178 / deviceScaler))
            path.addCurveToPoint(CGPointMake(155 / deviceScaler,199 / deviceScaler), controlPoint1: CGPointMake(168 / deviceScaler,191 / deviceScaler), controlPoint2: CGPointMake(155 / deviceScaler,199 / deviceScaler))
            path.addCurveToPoint(CGPointMake(145 / deviceScaler,214 / deviceScaler), controlPoint1: CGPointMake(155 / deviceScaler,199 / deviceScaler), controlPoint2: CGPointMake(145 / deviceScaler,207 / deviceScaler))
            path.addCurveToPoint(CGPointMake(145 / deviceScaler,311 / deviceScaler), controlPoint1: CGPointMake(145 / deviceScaler,221 / deviceScaler), controlPoint2: CGPointMake(145 / deviceScaler,311 / deviceScaler))
            path.addCurveToPoint(CGPointMake(131 / deviceScaler,322 / deviceScaler), controlPoint1: CGPointMake(145 / deviceScaler,311 / deviceScaler), controlPoint2: CGPointMake(146 / deviceScaler,322 / deviceScaler))
            path.addCurveToPoint(CGPointMake(53 / deviceScaler,322 / deviceScaler), controlPoint1: CGPointMake(116 / deviceScaler,322 / deviceScaler), controlPoint2: CGPointMake(53 / deviceScaler,322 / deviceScaler))
            path.addCurveToPoint(CGPointMake(53 / deviceScaler,322 / deviceScaler), controlPoint1: CGPointMake(116 / deviceScaler,322 / deviceScaler), controlPoint2: CGPointMake(53 / deviceScaler,322 / deviceScaler))
            path.addCurveToPoint(CGPointMake(40 / deviceScaler,313 / deviceScaler), controlPoint1: CGPointMake(53 / deviceScaler,322 / deviceScaler), controlPoint2: CGPointMake(40 / deviceScaler,322 / deviceScaler))
            path.addCurveToPoint(CGPointMake(40 / deviceScaler,312 / deviceScaler), controlPoint1: CGPointMake(40 / deviceScaler,304 / deviceScaler), controlPoint2: CGPointMake(40 / deviceScaler,312 / deviceScaler))
            fillColor.setFill()
            path.fill()
        } else if self.leftUpper {
            var path = UIBezierPath()
            path.moveToPoint(CGPointMake(0 / deviceScaler,309 / deviceScaler))
            path.addLineToPoint(CGPointMake(0 / deviceScaler,26 / deviceScaler))
            path.addCurveToPoint(CGPointMake(25 / deviceScaler,0 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,26 / deviceScaler), controlPoint2: CGPointMake(2 / deviceScaler,0 / deviceScaler))
            path.addCurveToPoint(CGPointMake(158 / deviceScaler,0 / deviceScaler), controlPoint1: CGPointMake(47 / deviceScaler,0 / deviceScaler), controlPoint2: CGPointMake(158 / deviceScaler,0 / deviceScaler))
            path.addCurveToPoint(CGPointMake(186 / deviceScaler,25 / deviceScaler), controlPoint1: CGPointMake(158 / deviceScaler,0 / deviceScaler), controlPoint2: CGPointMake(186 / deviceScaler,3 / deviceScaler))
            path.addCurveToPoint(CGPointMake(186 / deviceScaler,132 / deviceScaler), controlPoint1: CGPointMake(186 / deviceScaler,46 / deviceScaler), controlPoint2: CGPointMake(186 / deviceScaler,132 / deviceScaler))
            path.addCurveToPoint(CGPointMake(182 / deviceScaler,145 / deviceScaler), controlPoint1: CGPointMake(186 / deviceScaler,132 / deviceScaler), controlPoint2: CGPointMake(186 / deviceScaler,140 / deviceScaler))
            path.addCurveToPoint(CGPointMake(117 / deviceScaler,209 / deviceScaler), controlPoint1: CGPointMake(178 / deviceScaler,150 / deviceScaler), controlPoint2: CGPointMake(117 / deviceScaler,209 / deviceScaler))
            path.addCurveToPoint(CGPointMake(108 / deviceScaler,230 / deviceScaler), controlPoint1: CGPointMake(117 / deviceScaler,209 / deviceScaler), controlPoint2: CGPointMake(108 / deviceScaler,216 / deviceScaler))
            path.addCurveToPoint(CGPointMake(108 / deviceScaler,308 / deviceScaler), controlPoint1: CGPointMake(108 / deviceScaler,244 / deviceScaler), controlPoint2: CGPointMake(108 / deviceScaler,308 / deviceScaler))
            path.addCurveToPoint(CGPointMake(95 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(108 / deviceScaler,308 / deviceScaler), controlPoint2: CGPointMake(106 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(12 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(83 / deviceScaler / deviceScaler,321), controlPoint2: CGPointMake(12 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(0 / deviceScaler,310 / deviceScaler), controlPoint1: CGPointMake(12 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,319 / deviceScaler))
            path.addCurveToPoint(CGPointMake(0 / deviceScaler,309 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,301 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,309 / deviceScaler))
            fillColor.setFill()
            path.fill()
        } else if self.rightUpper {
            var path = UIBezierPath()
            path.moveToPoint(CGPointMake(184 / deviceScaler,309 / deviceScaler))
            path.addLineToPoint(CGPointMake(184 / deviceScaler,26 / deviceScaler))
            path.addCurveToPoint(CGPointMake(159 / deviceScaler,0 / deviceScaler), controlPoint1: CGPointMake(184 / deviceScaler,26 / deviceScaler), controlPoint2: CGPointMake(182 / deviceScaler,0 / deviceScaler))
            path.addCurveToPoint(CGPointMake(27 / deviceScaler,0 / deviceScaler), controlPoint1: CGPointMake(137 / deviceScaler,0 / deviceScaler), controlPoint2: CGPointMake(27 / deviceScaler,0 / deviceScaler))
            path.addCurveToPoint(CGPointMake(0 / deviceScaler,25 / deviceScaler), controlPoint1: CGPointMake(27 / deviceScaler,0 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,3 / deviceScaler))
            path.addCurveToPoint(CGPointMake(0 / deviceScaler,132 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,46 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,132 / deviceScaler))
            path.addCurveToPoint(CGPointMake(3 / deviceScaler,145 / deviceScaler), controlPoint1: CGPointMake(0 / deviceScaler,132 / deviceScaler), controlPoint2: CGPointMake(0 / deviceScaler,140 / deviceScaler))
            path.addCurveToPoint(CGPointMake(68 / deviceScaler,209 / deviceScaler), controlPoint1: CGPointMake(8 / deviceScaler,150 / deviceScaler), controlPoint2: CGPointMake(68 / deviceScaler,209 / deviceScaler))
            path.addCurveToPoint(CGPointMake(77 / deviceScaler,230 / deviceScaler), controlPoint1: CGPointMake(68 / deviceScaler,209 / deviceScaler), controlPoint2: CGPointMake(77 / deviceScaler,216 / deviceScaler))
            path.addCurveToPoint(CGPointMake(77 / deviceScaler,308 / deviceScaler), controlPoint1: CGPointMake(77 / deviceScaler,244 / deviceScaler), controlPoint2: CGPointMake(77 / deviceScaler,308 / deviceScaler))
            path.addCurveToPoint(CGPointMake(90 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(77 / deviceScaler,308 / deviceScaler), controlPoint2: CGPointMake(78 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(172 / deviceScaler,321 / deviceScaler), controlPoint1: CGPointMake(101 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(172 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(184 / deviceScaler,310 / deviceScaler), controlPoint1: CGPointMake(172 / deviceScaler,321 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,319 / deviceScaler))
            path.addCurveToPoint(CGPointMake(184 / deviceScaler,309 / deviceScaler), controlPoint1: CGPointMake(184 / deviceScaler,301 / deviceScaler), controlPoint2: CGPointMake(184 / deviceScaler,309 / deviceScaler))
            fillColor.setFill()
            path.fill()
        } else if self.specialWideKey {
            var path = UIBezierPath()
            path.moveToPoint(CGPointMake(33 / (deviceScaler / 1.3),310 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(21 / (deviceScaler / 1.3),197 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(33 / (deviceScaler / 1.3),214 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(31 / (deviceScaler / 1.3),203 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(0 / (deviceScaler / 1.3),172 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(12 / (deviceScaler / 1.3),192 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(0 / (deviceScaler / 1.3),179 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(0 / (deviceScaler / 1.3),73 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(0 / (deviceScaler / 1.3),164 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(0 / (deviceScaler / 1.3),73 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(23 / (deviceScaler / 1.3),50 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(0 / (deviceScaler / 1.3),73 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(0 / (deviceScaler / 1.3),50 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(162 / (deviceScaler / 1.3),50 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(47 / (deviceScaler / 1.3),50 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(162 / (deviceScaler / 1.3),50 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(184 / (deviceScaler / 1.3),76 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(162 / (deviceScaler / 1.3),50 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(184 / (deviceScaler / 1.3),49 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(184 / (deviceScaler / 1.3),171 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(184 / (deviceScaler / 1.3),104 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(184 / (deviceScaler / 1.3),171 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(176 / (deviceScaler / 1.3),186 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(184 / (deviceScaler / 1.3),171 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(183 / (deviceScaler / 1.3),178 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(152 / (deviceScaler / 1.3),216 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(169 / (deviceScaler / 1.3),194 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(152 / (deviceScaler / 1.3),201 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(151 / (deviceScaler / 1.3),310 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(151 / (deviceScaler / 1.3),231 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(151 / (deviceScaler / 1.3),310 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(140 / (deviceScaler / 1.3),322 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(151 / (deviceScaler / 1.3),310 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(153 / (deviceScaler / 1.3),322 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(46 / (deviceScaler / 1.3),322 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(126 / (deviceScaler / 1.3),322 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(46 / (deviceScaler / 1.3),322 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(33 / (deviceScaler / 1.3),311 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(46 / (deviceScaler / 1.3),322 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(33 / (deviceScaler / 1.3),322 / (deviceScaler / 1.3)))
            path.addCurveToPoint(CGPointMake(33 / (deviceScaler / 1.3),310 / (deviceScaler / 1.3)), controlPoint1: CGPointMake(33 / (deviceScaler / 1.3),299 / (deviceScaler / 1.3)), controlPoint2: CGPointMake(33 / (deviceScaler / 1.3),310 / (deviceScaler / 1.3)))
            fillColor.setFill()
            path.fill()
        } else {
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
            path.addCurveToPoint(CGPointMake(39 / deviceScaler,310 / deviceScaler), controlPoint1: CGPointMake(53 / deviceScaler,321 / deviceScaler), controlPoint2:    CGPointMake(39 / deviceScaler,321 / deviceScaler))
            path.addCurveToPoint(CGPointMake(39 / deviceScaler,309 / deviceScaler), controlPoint1: CGPointMake(39 / deviceScaler,299 / deviceScaler), controlPoint2: CGPointMake(39 / deviceScaler,309 / deviceScaler))
            fillColor.setFill()
            path.fill()
        }
    }
}
