//
//  ProfileTableViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class ProfileTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
	
	var profiles = [NSManagedObject]()
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchProfiles()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "profileUpdated:", name: "ProfileUpdated", object: nil)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
		case "showDetail":
			if let indexPath = self.tableView.indexPathForSelectedRow() {
				let profile = profiles[indexPath.row]
				let controller = (segue.destinationViewController as! UINavigationController).topViewController as! ProfileDetailViewController
				
				controller.profile = profile
			}
		//case "showSettings":
		case "addProfile":
			let controller = (segue.destinationViewController as! UINavigationController).topViewController as! ProfileDetailViewController
			controller.profile = nil
			controller.setEditing(true, animated: false)
		default:
			println("Default segue")
		}
	}
	
	// MARK: - Table View Data Source
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return profiles.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
		
		let profile = profiles[indexPath.row]
		cell.textLabel?.text = profile.valueForKey("name") as! String?
		
		return cell
	}
	
	// MARK: - Table View Delegate
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if(editingStyle == .Delete ) {
			let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
			let managedContext = appDelegate.managedObjectContext!
			let profileToDelete = profiles[indexPath.row]
			
			managedContext.deleteObject(profileToDelete)
			self.fetchProfiles()
			
			//tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
			
			var error : NSError?
			if (managedContext.save(&error) ) {
				println(error?.localizedDescription)
			}
		}
	}
	
	// MARK: - Core Data
	
	func profileUpdated(notification: NSNotification) {
		fetchProfiles()
	}
	
	func fetchProfiles() {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		let fetchRequest = NSFetchRequest(entityName: "Profiles")
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		var error: NSError?
		let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
		if let results = fetchedResults {
			profiles = results
		} else {
			println("Could not fetch \(error), \(error!.userInfo)")
		}
		
		tableView.reloadData()
	}
}
