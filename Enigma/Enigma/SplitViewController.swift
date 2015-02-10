//
//  SplitViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/7/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
	@IBAction func unwindTutorial(sender: UIStoryboardSegue) {
		var userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setBool(true, forKey: "hasSeenTutorial")
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		var userDefaults = NSUserDefaults.standardUserDefaults()
		if (userDefaults.boolForKey("hasSeenTutorial") == false) {
			performSegueWithIdentifier("showTutorial", sender: self)
		}
		
		setNeedsStatusBarAppearanceUpdate()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
}
