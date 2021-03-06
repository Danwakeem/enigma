//
//  BlockButton.swift
//  Enigma
//
//  Created by Jake Singer on 2/9/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

@IBDesignable
class BlockButton: UIButton {
	override func intrinsicContentSize() -> CGSize {
		var contentSize = super.intrinsicContentSize()
		return CGSize(width: contentSize.width + 40, height: contentSize.height + 10)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = 6.0
		self.layer.masksToBounds = true
	}
}
