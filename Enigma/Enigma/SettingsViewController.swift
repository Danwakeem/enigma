//
//  SettingsViewController.swift
//  Enigma
//
//  Created by Bradley Slayter on 2/13/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
	
	override func viewDidLoad() {
		
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
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
		return false
	}
	
	func switchTapped(sender: AnyObject) {
		
	}
	
	func createSwitch(index: Int) -> UISwitch {
		let newSwitch = UISwitch();
		newSwitch.addTarget(self, action: "switchTapped:", forControlEvents: .ValueChanged)
		newSwitch.tag = index
		
		newSwitch.setOn(checkSwitchStatus(index), animated: false)
		
		return newSwitch
	}
	
}
