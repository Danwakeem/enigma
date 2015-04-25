//
//  TutorialModelController.swift
//  Enigma
//
//  Created by Jake Singer on 2/7/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class TutorialModelController: NSObject, UIPageViewControllerDataSource {
	var pageData = NSArray()
	var identifiers = [ "TutorialPageViewController_Start", "TutorialPageViewController_Choice", "TutorialPageViewController_ProfileTut", "TutorialPageViewController_KeyboardTut", "TutorialPageViewController_Final" ]
	
	override init() {
		super.init()
		
		pageData = [ "Welcome!", "Enable Passcode/TouchID?", "Creating A Profile", "Using The Keyboard", "Enable Full Access." ]
	}
	
	func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> TutorialPageViewController? {
		// Return the data view controller for the given index.
		if (self.pageData.count == 0) || (index >= self.pageData.count) {
			return nil
		}
		
		// Create a new view controller and pass suitable data.
		let pageViewController = storyboard.instantiateViewControllerWithIdentifier(identifiers[index]) as! TutorialPageViewController
		pageViewController.dataObject = pageData[index]
		return pageViewController
	}
	
	func indexOfViewController(viewController: TutorialPageViewController) -> Int {
		if let dataObject: AnyObject = viewController.dataObject {
			return self.pageData.indexOfObject(dataObject)
		} else {
			return NSNotFound
		}
		
	}
	
	// MARK: - Page View Controller Data Source
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		var index = self.indexOfViewController(viewController as! TutorialPageViewController)
		if (index == 0) || (index == NSNotFound) {
			return nil
		}
		
		index--
		return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
	}
	
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		var index = self.indexOfViewController(viewController as! TutorialPageViewController)
		if index == NSNotFound {
			return nil
		}
		
		index++
		if index == self.pageData.count {
			return nil
		}
		return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
	}
}
