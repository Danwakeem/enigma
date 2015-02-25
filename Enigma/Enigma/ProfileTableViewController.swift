//
//  ProfileTableViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class ProfileTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, NewProfilePopupViewControllerDelegate {
	var detailViewController: ProfileDetailViewController? = nil
    var appDelegate = AppDelegate()
    var managedObjectContext: NSManagedObjectContext? = nil
    var addProfileView: NewProfilePopupViewController?
	
	let testProfileNames = [ "Sydney", "Jacob Smith", "Derek Facebook", "John iMessage", "John WhatsApp", "Sara Email" ]
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.managedObjectContext = self.appDelegate.managedObjectContext!
		if let split = self.splitViewController {
			let controllers = split.viewControllers
			self.detailViewController = controllers[controllers.count-1].topViewController as? ProfileDetailViewController
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
    
    
    func closePop(sender:AnyObject) {
        if let name = self.addProfileView?.nameField.text {
            self.insertNewObject(name)
        }
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func cancelPop(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    @IBAction func modal(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        self.addProfileView = (sb.instantiateViewControllerWithIdentifier("popper")! as NewProfilePopupViewController)
        self.addProfileView!.delegate = self
        
        self.addProfileView!.modalTransitionStyle = .CoverVertical
        self.addProfileView!.modalPresentationStyle = .FullScreen
        
        self.addProfileView!.preferredContentSize = CGSize(width:self.view.frame.width * CGFloat(1 / 100.0), height:self.view.frame.height * CGFloat(1 / 100.0))
        
        if addProfileView != nil{
            self.presentViewController(addProfileView!, animated: true, completion: {})
        }
    }
    
    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newProfile = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as NSManagedObject
        let basicEncryption = NSEntityDescription.insertNewObjectForEntityForName("Encryptions", inManagedObjectContext: context) as NSManagedObject
        let secondEncryption = NSEntityDescription.insertNewObjectForEntityForName("Encryptions", inManagedObjectContext: context) as NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        var name: String = sender as String
        newProfile.setValue(sender, forKey: "name")
        newProfile.setValue(NSDate(), forKey: "timestamp")
        
        basicEncryption.setValue("Caesar", forKey: "encryptionType")
        basicEncryption.setValue("13", forKey: "key1")
        basicEncryption.setValue("", forKey: "key2")
        basicEncryption.setValue(newProfile, forKey: "profiles")
        
        secondEncryption.setValue("Affine", forKey: "encryptionType")
        secondEncryption.setValue("9", forKey: "key1")
        secondEncryption.setValue("23", forKey: "key2")
        secondEncryption.setValue(newProfile, forKey: "profiles")
        
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
    }
	
	// MARK: - Segues
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
                let controller = (segue.destinationViewController as UINavigationController).topViewController as ProfileDetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
	}
    
	// MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
        
        /*
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		
		let item = testProfileNames[indexPath.row]
		cell.textLabel?.text = item
		
		return cell
        */
	}
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
            
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        cell.textLabel?.text = object.valueForKey("name")!.description
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Profiles", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        //We may want to limit the size of the request
        //fetchRequest.fetchBatchSize = 20
        
        // If we want to sort the results of the query this is how we could do it.
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Profile Table View Controller")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    /*
    // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    self.tableView.reloadData()
    }
    */
}
