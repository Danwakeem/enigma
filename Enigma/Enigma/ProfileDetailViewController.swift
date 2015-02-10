//
//  ProfileDetailViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class ProfileDetailViewController: UIViewController {
	
	@IBOutlet weak var nameLabel: UILabel!
	var name: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		nameLabel.text = name
		
		// Will add the ability to edit the name inside of the title bar
		/*
		var textField = UITextField(frame: CGRect())
		textField.text = title
		textField.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
		textField.textAlignment = .Center
		textField.backgroundColor = UIColor.clearColor()
		textField.textColor = UIColor.whiteColor()
		textField.layer.cornerRadius = 6.0
		textField.layer.masksToBounds = true
		textField.layer.borderColor = UIColor(white: 1.0, alpha: 0.75).CGColor
		textField.layer.borderWidth = 0.5
		navigationItem.titleView = textField
		*/
		
		setNeedsStatusBarAppearanceUpdate()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
