//
//  PasscodeButton.swift
//  Enigma
//
//  Created by Bradley Slayter on 2/6/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class PasscodeButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
	
	override var highlighted: Bool {
		get {
			return super.highlighted
		}
		set {
			if newValue {
				backgroundColor = UIColor.init(CGColor: self.layer.borderColor)
			} else {
				backgroundColor = UIColor.clearColor()
			}
			super.highlighted = newValue
		}
	}

}
