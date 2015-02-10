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
		
		setNeedsStatusBarAppearanceUpdate()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
