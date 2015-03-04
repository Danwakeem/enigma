//
//  SplitViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/7/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate, PasscodeViewDelegate {
	
	var authenticated = false
    
	var managedObjectContext: NSManagedObjectContext? = nil

	@IBAction func unwindTutorial(sender: UIStoryboardSegue) {
		var userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setBool(true, forKey: "hasSeenTutorial")
		authenticated = true
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		delegate = self
		
		//let navigationController = viewControllers[viewControllers.count-1] as UINavigationController
		//navigationController.topViewController.navigationItem.leftBarButtonItem = displayModeButtonItem()
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
		return true
	}
	
	func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
		return false
	}
}
