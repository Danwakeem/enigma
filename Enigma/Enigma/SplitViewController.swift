//
//  SplitViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/7/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
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
		}
		
		setNeedsStatusBarAppearanceUpdate()
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
