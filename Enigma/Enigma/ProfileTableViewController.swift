//
//  ProfileTableViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class ProfileTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, AMScanViewControllerDelegate, UIAlertViewDelegate {
	
	var profiles = [NSManagedObject]()
	
	var allowScaning = false
	var profileToImport: NSManagedObject?
	let kPorfileNameAlertTag = 50
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchProfiles()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "profileUpdated:", name: "ProfileUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "profileFromURL:", name: "ProfileFromURL", object: nil)
		
		let btn = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "showScanner")
		if let rightBtn = self.navigationItem.rightBarButtonItem {
			let btnsArray = [btn, rightBtn]
			self.navigationItem.rightBarButtonItems = btnsArray
		}
		
	}
	
	func showScanner() {
		let vc = AMScanViewController()
		vc.delegate = self
		self.presentViewController(vc, animated: true, completion: {
			self.allowScaning = true
		})
	}
	
	func scanViewController(aCtler: AMScanViewController!, didSuccessfullyScan aScannedValue: String!) {
		if self.allowScaning {
			self.allowScaning = false
			self.dismissViewControllerAnimated(true, completion: nil)
			importFromQRCode(aScannedValue)
		}
	}
	
	func importFromQRCode(profile: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.parseProfile(profile)
	}
	
	func finishImportingProfile(newName: String) {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		profileToImport?.setValue(newName, forKey: "name")
		
		var error: NSError?
		if !managedContext.save(&error) {
			println("Could not save \(error), \(error?.userInfo)")
		}
		
		NSNotificationCenter.defaultCenter().postNotificationName("ProfileUpdated", object: profileToImport)
	}
	
	func cancelImport() {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		managedContext.deleteObject(profileToImport!)
		
		fetchProfiles()
	}
	
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		if alertView.tag == kPorfileNameAlertTag {
			println("Delegate called! \(buttonIndex)")
			switch (buttonIndex) {
			case alertView.cancelButtonIndex:
				cancelImport()
			case 1:
				if let newName = alertView.textFieldAtIndex(0)?.text {
					if newName != "" {
						println("Finalize")
						finishImportingProfile(newName)
					} else {
						println("Empty String")
						if let profileName = profileToImport?.valueForKey("name") as? String {
							let alert = UIAlertView(title: "Error", message: "Please enter a name for this profile", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Save", "Use \"" + profileName + "\"")
							alert.alertViewStyle = .PlainTextInput
							alert.tag = kPorfileNameAlertTag
							alert.show()
						}
					}
				} else {
					println("Something weird happened")
				}
			case 2:
				if let profileName = profileToImport?.valueForKey("name") as? String {
					finishImportingProfile(profileName)
				}
			default:
				break
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
    
    func profileFromURL(sender: AnyObject){
        if let profile = sender.object as? NSManagedObject {
            var index: Int = find(profiles,profile)!
            tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition(rawValue: 0)!)
            performSegueWithIdentifier("importProfile", sender: self)
        } else {
            println("Fuck")
        }
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
            
        case "importProfile":
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let profile = profiles[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! ProfileDetailViewController
                
                controller.profile = profile
                controller.setEditing(true, animated: false)
            }
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
