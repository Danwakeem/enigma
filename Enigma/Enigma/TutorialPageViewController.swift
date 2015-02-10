//
//  TutorialPageViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/7/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

protocol TutorialPageViewControllerDelegate {
	func pageRequestedForController(controller: TutorialPageViewController, direction: UIPageViewControllerNavigationDirection)
}

class TutorialPageViewController: UIViewController {
	
	@IBOutlet weak var dataLabel: UILabel!
	
	@IBOutlet weak var backButton: BlockButton!
	@IBOutlet weak var nextButton: BlockButton!
	
	var delegate: TutorialPageViewControllerDelegate! = nil
	var dataObject: AnyObject?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		dataLabel!.text = dataObject != nil ? dataObject!.description : ""
	}
	
	@IBAction func next(sender: AnyObject) {
		delegate!.pageRequestedForController(self, direction: .Forward)
	}
	
	@IBAction func back(sender: AnyObject) {
		delegate!.pageRequestedForController(self, direction: .Reverse)
	}
	
	@IBAction func enableSecurity(sender: AnyObject) {
		// TODO: show passcode creation screen then touch id screen
	}
}
