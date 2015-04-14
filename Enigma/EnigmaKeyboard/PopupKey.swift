//
//  PopupKey.swift
//  Enigma
//
//  Created by Dan jarvis on 4/13/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class PopupKey: UIView {
    
    var title = UIButton()
    var buttonBackgroundColor: UIColor!
    var textColor: UIColor!
    
    init(title: String){
        super.init(frame: CGRectZero)
        //self.backgroundColor = UIColor.clearColor()
        self.title.setTitle(title, forState: .Normal)
        //self.setUpTitleButton()
    }

    init(backgroundColor: UIColor, textColor: UIColor){
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
        self.drawRect(CGRectZero)
        self.buttonBackgroundColor = backgroundColor
        self.textColor = textColor
        self.title.setTitle("H", forState: .Normal)
        self.setUpTitleButton()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpTitleButton() {
        self.title.setTitleColor(self.textColor, forState: .Normal)
        self.title.backgroundColor = self.buttonBackgroundColor
        self.title.titleLabel?.font = UIFont.systemFontOfSize(40)
        self.title.enabled = false
        self.title.layer.cornerRadius = 5
        self.title.layer.masksToBounds = false
        self.title.layer.shadowColor = UIColor.blackColor().CGColor
        self.title.layer.shadowOpacity = 0.2
        self.title.layer.shadowRadius = 5
        self.title.layer.shadowOffset = CGSizeMake(0, 3)
        self.addSubview(self.title)
        self.title.setTranslatesAutoresizingMaskIntoConstraints(false)
        let top = NSLayoutConstraint(item: self.title, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.title, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: self.title, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: self.title, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)
        self.addConstraints([top,bottom,right,left])
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        var fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        var path = UIBezierPath()
        path.moveToPoint(CGPointMake(39 / 4,309 / 4))
        path.addLineToPoint(CGPointMake(39 / 4,187 / 4))
        path.addCurveToPoint(CGPointMake(31 / 4,170 / 4), controlPoint1: CGPointMake(39 / 4,187 / 4), controlPoint2: CGPointMake(39 / 4,177 / 4))
        path.addCurveToPoint(CGPointMake(7 / 4,149 / 4), controlPoint1: CGPointMake(22 / 4,163 / 4), controlPoint2: CGPointMake(7 / 4,149 / 4))
        path.addCurveToPoint(CGPointMake(0 / 4,131 / 4), controlPoint1: CGPointMake(7 / 4,149 / 4), controlPoint2: CGPointMake(0 / 4,141 / 4))
        path.addCurveToPoint(CGPointMake(0 / 4,25 / 4), controlPoint1: CGPointMake(0 / 4,121 / 4), controlPoint2: CGPointMake(0 / 4,25 / 4))
        path.addCurveToPoint(CGPointMake(27 / 4,0 / 4), controlPoint1: CGPointMake(0 / 4,25 / 4), controlPoint2: CGPointMake(3 / 4,0 / 4))
        path.addCurveToPoint(CGPointMake(158 / 4,0 / 4), controlPoint1: CGPointMake(50 / 4,0 / 4), controlPoint2: CGPointMake(158 / 4,0 / 4))
        path.addCurveToPoint(CGPointMake(184 / 4,27 / 4), controlPoint1: CGPointMake(158 / 4,0 / 4), controlPoint2: CGPointMake(183 / 4,2 / 4))
        path.addCurveToPoint(CGPointMake(184 / 4,132 / 4), controlPoint1: CGPointMake(184 / 4,52 / 4), controlPoint2: CGPointMake(184 / 4,132 / 4))
        path.addCurveToPoint(CGPointMake(176 / 4,150 / 4), controlPoint1: CGPointMake(184 / 4,132 / 4), controlPoint2: CGPointMake(184 / 4,141 / 4))
        path.addCurveToPoint(CGPointMake(155 / 4,168 / 4), controlPoint1: CGPointMake(168 / 4,158 / 4), controlPoint2: CGPointMake(155 / 4,168 / 4))
        path.addCurveToPoint(CGPointMake(145 / 4,187 / 4), controlPoint1: CGPointMake(155 / 4,168 / 4), controlPoint2: CGPointMake(145 / 4,178 / 4))
        path.addCurveToPoint(CGPointMake(144 / 4,308 / 4), controlPoint1: CGPointMake(145 / 4,196 / 4), controlPoint2: CGPointMake(144 / 4,308 / 4))
        path.addCurveToPoint(CGPointMake(130 / 4,321 / 4), controlPoint1: CGPointMake(144 / 4,308 / 4), controlPoint2: CGPointMake(145 / 4,321 / 4))
        path.addCurveToPoint(CGPointMake(53 / 4,321 / 4), controlPoint1: CGPointMake(115 / 4,321 / 4), controlPoint2: CGPointMake(53 / 4,321 / 4))
        path.addCurveToPoint(CGPointMake(39 / 4,310 / 4), controlPoint1: CGPointMake(53 / 4,321 / 4), controlPoint2: CGPointMake(39 / 4,321 / 4))
        path.addCurveToPoint(CGPointMake(39 / 4,309 / 4), controlPoint1: CGPointMake(39 / 4,299 / 4), controlPoint2: CGPointMake(39 / 4,309 / 4))
        fillColor.setFill()
        path.fill()
    }
}
