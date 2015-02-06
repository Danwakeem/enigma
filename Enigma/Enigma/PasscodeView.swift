//
//  PasscodeViewViewController.swift
//  Enigma
//
//  Created by Bradley Slayter on 2/6/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class PasscodeView: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = UIColor.whiteColor()
		
        /*let btn5 = UIButton()
		btn5.frame = CGRectMake(0, 0, 50, 50)
		btn5.center = self.view.center
		btn5.setTitle("5", forState: .Normal)
		btn5.setTitleColor(UIColor.blackColor(), forState: .Normal)
		btn5.layer.borderColor = UIColor.redColor().CGColor
		btn5.layer.borderWidth = 2.0
		btn5.layer.cornerRadius = 25
		btn5.addTarget(self, action: "btnClicked:", forControlEvents: .TouchDown)
		btn5.addTarget(self, action: "btnReleased:", forControlEvents: .TouchUpInside)
		
		self.view.addSubview(btn5)*/
		
		createBtns()
		
    }
	
	func createBtns() {
		let startX = self.view.center.x - 90
		let startY = self.view.center.y - 90
		
		var row = 0
		for var i = 0; i < 10; i++ {
			let btn = UIButton()
			btn.frame = CGRectMake(0, 0, 70, 70)
			btn.center = CGPointMake(startX + CGFloat((i%3) * 90), startY + CGFloat(row * 90))
			btn.setTitle(String(i+1), forState: .Normal)
			btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
			btn.layer.borderColor = UIColor.redColor().CGColor
			btn.layer.borderWidth = 2.0
			btn.layer.cornerRadius = 35
			btn.addTarget(self, action: "btnClicked:", forControlEvents: .TouchDown)
			btn.addTarget(self, action: "btnReleased:", forControlEvents: .TouchUpInside)
			self.view.addSubview(btn)
			
			if i == 9 {
				btn.center = CGPointMake(btn.center.x + 90, btn.center.y)
				btn.setTitle("0", forState: .Normal)
			}
			
			if ((i+1) % 3 == 0) {
				row++
			}
		}
	}
	
	func btnClicked(sender: AnyObject) {
		let btn = sender as UIButton
		btn.backgroundColor = UIColor.init(CGColor: btn.layer.borderColor)
		btn.setTitleColor(btn.backgroundColor, forState: .Normal)
	}
	
	func btnReleased(sender: AnyObject) {
		let btn = sender as UIButton
		btn.backgroundColor = UIColor.clearColor()
		btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
