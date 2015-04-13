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
        self.backgroundColor = UIColor.clearColor()
        self.title.setTitle(title, forState: .Normal)
        self.setUpTitleButton()
    }

    init(backgroundColor: UIColor, textColor: UIColor){
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor.clearColor()
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

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
