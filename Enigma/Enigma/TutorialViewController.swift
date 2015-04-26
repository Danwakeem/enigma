//
//  TutorialViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDelegate, TutorialPageViewControllerDelegate {
	
	@IBOutlet weak var pageControl: UIPageControl!
	var pageViewController: UIPageViewController?
	
	var modelController: TutorialModelController {
		struct _modelController {
			static let instance = TutorialModelController()
		}
		return _modelController.instance
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let startingViewController: TutorialPageViewController = modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
		startingViewController.delegate = self
		let viewControllers: NSArray = [startingViewController]
		pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: false, completion: {done in })
		pageViewController!.dataSource = self.modelController
		pageControl.numberOfPages = modelController.pageData.count
		
		view.gestureRecognizers = self.pageViewController!.gestureRecognizers
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "pageViewController" {
			pageViewController = segue.destinationViewController as? UIPageViewController
			pageViewController!.delegate = self
		}
	}
	
	// MARK: - UIPageViewControllerDelegate
	
	func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
		var currentViewController: TutorialPageViewController = pageViewController.viewControllers[0] as! TutorialPageViewController;
		currentViewController.delegate = self
		pageControl.currentPage = modelController.indexOfViewController(currentViewController)
	}
	
	// MARK: - TutorialPageViewControllerDelegate
	
	func pageRequestedForController(controller: TutorialPageViewController, direction: UIPageViewControllerNavigationDirection) {
		var nextViewController: TutorialPageViewController?
		
		// determine the page to change to
		switch direction {
		case .Forward:
			nextViewController = modelController.pageViewController(pageViewController!, viewControllerAfterViewController: controller) as! TutorialPageViewController?
		case .Reverse:
			nextViewController = modelController.pageViewController(pageViewController!, viewControllerBeforeViewController: controller) as! TutorialPageViewController?
		}
		
		// go to the page, or end the tutorial if no more pages exist
		if nextViewController != nil {
			var viewControllers: NSArray = [nextViewController!]
			pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: direction, animated: true) {
				done in
				self.pageViewController(self.pageViewController!, didFinishAnimating: done, previousViewControllers: [controller], transitionCompleted: true)
			}
		} else {
			performSegueWithIdentifier("unwindTutorial", sender: self)
		}
	}
}
