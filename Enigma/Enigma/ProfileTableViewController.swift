//
//  ProfileTableViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
	var detailViewController: ProfileDetailViewController? = nil
	
	let testProfileNames = [ "Sydney", "Jacob Smith", "Derek Facebook", "John iMessage", "John WhatsApp", "Sara Email" ]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let split = self.splitViewController {
			let controllers = split.viewControllers
			self.detailViewController = controllers[controllers.count-1].topViewController as? ProfileDetailViewController
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow() {
				let name = testProfileNames[indexPath.row] as String
				let controller = (segue.destinationViewController as UINavigationController).topViewController as ProfileDetailViewController
				
				//controller.title = name
				controller.name = name
				
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}
	
	// MARK: - Table View
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return testProfileNames.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		
		let item = testProfileNames[indexPath.row]
		cell.textLabel?.text = item
		
		return cell
	}
}
