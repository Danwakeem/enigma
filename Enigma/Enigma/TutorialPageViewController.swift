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

class TutorialPageViewController: UIViewController, PasscodeViewDelegate {
	
	@IBOutlet weak var dataLabel: UILabel!
	
	@IBOutlet weak var backButton: BlockButton!
	@IBOutlet weak var nextButton: BlockButton!
    
    @IBOutlet weak var tutorialGif: FLAnimatedImageView!
    
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
        
        if let gif = tutorialGif {
            loadGif()
        }
	}
    
    func loadGif(){
        let gifData: NSData!
        if self.dataLabel.text == "Creating A Profile" {
            gifData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("ProfileTut", ofType: "gif")!)
        } else {
            gifData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("KeyboardTut", ofType: "gif")!)
        }
        var gif = FLAnimatedImage(animatedGIFData: gifData!)
        tutorialGif.animatedImage = gif
        tutorialGif.layer.borderColor = UIColor.lightGrayColor().CGColor
        tutorialGif.layer.borderWidth = 1.0
        self.view.addSubview(tutorialGif)
    }
	
	@IBAction func next(sender: AnyObject) {
		delegate!.pageRequestedForController(self, direction: .Forward)
	}
	
	@IBAction func back(sender: AnyObject) {
		delegate!.pageRequestedForController(self, direction: .Reverse)
	}
	
	@IBAction func enableSecurity(sender: AnyObject) {
		performSegueWithIdentifier("showPasscodeView", sender: self)
	}
	
	func authenticationCompleted(success: Bool) {
		if success {
			next(self)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showPasscodeView" {
			var passcodeView = segue.destinationViewController as! PasscodeView
			passcodeView.delegate = self
			passcodeView.setup = true
		}
	}
}
