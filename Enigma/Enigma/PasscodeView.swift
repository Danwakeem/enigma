//
//  PasscodeViewViewController.swift
//  Enigma
//
//  Created by Bradley Slayter on 2/6/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class PasscodeView: UIViewController {

	let dots = [] as NSMutableArray
	var dotCnt = 0
	
	var passcode = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = UIColor.whiteColor()
		
		createBtns()
		createDots()
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
			btn.layer.borderColor = UIColor(red: (52.0/255.0), green: (170.0/255.0), blue: (220.0/255.0), alpha: 1.0).CGColor
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
		
		let deleteBtn = UIButton()
		deleteBtn.frame = CGRectMake(0, 0, 150, 70)
		deleteBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 270)
		deleteBtn.setTitle("delete", forState: .Normal)
		deleteBtn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
		deleteBtn.addTarget(self, action: "deleteTapped:", forControlEvents: .TouchUpInside)
		self.view.addSubview(deleteBtn)
	}
	
	func createDots() {
		let startX = self.view.center.x - 45
		let startY = self.view.center.y - 180
		
		for var i = 0; i < 4; i++ {
			let dot = UIView()
			dot.frame = CGRectMake(0, 0, 15, 15)
			dot.center = CGPointMake(startX + CGFloat(i * 30), startY)
			dot.layer.borderWidth = 1.25
			dot.layer.borderColor = UIColor.darkGrayColor().CGColor
			dot.layer.cornerRadius = 7.5
			
			dots.addObject(dot)
			self.view.addSubview(dot)
		}
		
		let passcodeLbl = UILabel()
		passcodeLbl.frame = CGRectMake(0, 0, 150, 70)
		passcodeLbl.center = CGPointMake(self.view.center.x, self.view.center.y - 210)
		passcodeLbl.text = "Passcode Required"
		passcodeLbl.textColor = UIColor.blackColor()
		self.view.addSubview(passcodeLbl)
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
		
		if (dotCnt < 4) {
			let dot = dots[dotCnt] as UIView
			dot.backgroundColor = UIColor.init(CGColor: dot.layer.borderColor)
			dotCnt++
			
			passcode += btn.titleLabel!.text!
			
			if dotCnt == 4 {
				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}
	
	func deleteTapped(sender: AnyObject) {
		if dotCnt > 0 {
			dotCnt--
			let dot = dots[dotCnt] as UIView
			dot.backgroundColor = UIColor.clearColor()
			
			passcode = passcode.substringToIndex(passcode.endIndex.predecessor())
		}
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
