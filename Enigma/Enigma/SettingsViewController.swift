//
//  SettingsViewController.swift
//  Enigma
//
//  Created by Bradley Slayter on 2/13/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, PasscodeViewDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4;
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return (UIScreen.mainScreen().bounds.size.height-44.0)/4
	}
	
	@IBAction func doneTapped(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Touch ID/Passcode"
			cell.detailTextLabel?.text = "Enable touch ID to get access to this app"
		case 1:
			cell.textLabel?.text = "Quick Period"
			cell.detailTextLabel?.text = "Double tap the space bar to insert a period"
		case 2:
			cell.textLabel?.text = "Swipe to Change Profiles"
			cell.detailTextLabel?.text = "Right swipe across the clear text bar to\nchange encryption profiles"
		case 3:
			cell.textLabel?.text = "Color Scheme"
			cell.detailTextLabel?.text = "Change the color of the keyboard"
		default:
			cell.textLabel?.text = ""
		}
		
		if indexPath.row < 3 {
			cell.accessoryView = createSwitch(indexPath.row)
		}
		
		return cell
	}
	
	func checkSwitchStatus(index: Int) -> Bool {
		let defaults = NSUserDefaults.standardUserDefaults()
		
		switch index {
		case 0:
			if defaults.boolForKey("PasscodeSet") {
				return true
			}
		case 1:
			if defaults.boolForKey("QuickPeriod") {
				return true
			}
		case 2:
			if defaults.boolForKey("ProfileSwipe") {
				return true
			}
		default:
			return false
		}
		
		return false
	}
	
	func setPasscode() {
		let vc = PasscodeView()
		vc.setup = true
		vc.delegate = self
		self.presentViewController(vc, animated: true, completion: nil)
	}
	
	func authenticationCompleted(success: Bool) {
		println("We did it!")
	}
	
	func switchTapped(sender: AnyObject) {
		let selectedSwitch = sender as UISwitch
		let defaults = NSUserDefaults.standardUserDefaults()
		
		switch selectedSwitch.tag {
		case 0:
			if !selectedSwitch.on {
				defaults.setBool(false, forKey: "PasscodeSet")
				defaults.setObject("", forKey: "passcode")
			} else {
				setPasscode()
			}
		case 1:
			defaults.setBool(selectedSwitch.on, forKey: "QuickPeriod")
		case 2:
			defaults.setBool(selectedSwitch.on, forKey: "ProfileSwipe")
		default:
			break
		}
	}
	
	func createSwitch(index: Int) -> UISwitch {
		let newSwitch = UISwitch();
		newSwitch.addTarget(self, action: "switchTapped:", forControlEvents: .ValueChanged)
		newSwitch.tag = index
		
		newSwitch.setOn(checkSwitchStatus(index), animated: false)
		
		return newSwitch
	}
	
}
