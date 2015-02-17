//
//  SplitViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/7/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate, PasscodeViewDelegate {
	
	var authenticated = false
	
	@IBAction func unwindTutorial(sender: UIStoryboardSegue) {
		var userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setBool(true, forKey: "hasSeenTutorial")
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		delegate = self
		
		let navigationController = viewControllers[viewControllers.count-1] as UINavigationController
		navigationController.topViewController.navigationItem.leftBarButtonItem = displayModeButtonItem()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		
		var userDefaults = NSUserDefaults.standardUserDefaults()
		if (userDefaults.boolForKey("hasSeenTutorial") == false) {
			performSegueWithIdentifier("showTutorial", sender: self)
		} else {
			if userDefaults.boolForKey("PasscodeSet") && !authenticated {
				let vc = PasscodeView()
				vc.delegate = self
				vc.setup = false
				self.presentViewController(vc, animated: true, completion: nil)
			} else {
				authenticated = true
			}
		}
		
		setNeedsStatusBarAppearanceUpdate()
	}
	
	func authenticationCompleted(success: Bool) {
		println("We did it!")
		authenticated = true
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
	
	// MARK: - UISplitViewControllerDelegate
	
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
		if let secondaryAsNavController = secondaryViewController as? UINavigationController {
			if let topAsDetailController = secondaryAsNavController.topViewController as? ProfileDetailViewController {
				if topAsDetailController.name == "" {
					// Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
					return true
				}
			}
		}
		return false
	}
	
	func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
		return false
	}
}
