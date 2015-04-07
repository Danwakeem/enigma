//
//  ProfileTableView.swift
//  Enigma
//
//  Created by Dan jarvis on 3/28/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class ProfileTableView: UIView, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    var managedObjectContext = CoreDataStack().managedObjectContext
    
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var clearText: UIButton!
    
    
    var selectedProfile: NSManagedObject!
    let notificationKey = "com.SlayterDev.selectedProfile"
    
    var fetchedResultsController: NSFetchedResultsController!
    
    required override init() {
        super.init(frame: CGRectZero)
        if self.profileTable != nil {
            self.profileTable.reloadData()
        }
        self.loadFromNib()
    }
    
    init(fetchedResultsController: NSFetchedResultsController) {
        super.init(frame: CGRectZero)
        self.fetchedResultsController = fetchedResultsController
        if self.profileTable != nil {
            self.profileTable.reloadData()
        }
        self.loadFromNib()
    }
    
    func loadFromNib() {
        let rootView = NSBundle(forClass: self.dynamicType).loadNibNamed("Profiles", owner: self, options: nil)[0] as UIView
        
        self.addSubview(rootView)
        rootView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let left = NSLayoutConstraint(item: rootView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: rootView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: rootView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: rootView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        self.addConstraint(left)
        self.addConstraint(right)
        self.addConstraint(top)
        self.addConstraint(bottom)
        
        self.profileTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.profileTable.estimatedRowHeight = 44;
        self.profileTable.rowHeight = UITableViewAutomaticDimension;
        self.profileTable.allowsSelection = true
        
        // XXX: this is here b/c a totally transparent background does not support scrolling in blank areas
        self.profileTable.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.01)
        
        self.updateAppearance()
    }
    
    func updateAppearance(){
        let blueColor = UIColor(red: 0/CGFloat(255), green: 122/CGFloat(255), blue: 255/CGFloat(255), alpha: 1)
        
        self.backButton.setTitleColor(blueColor, forState: UIControlState.Normal)
        //self.backButton?.setTitleColor(blueColor, forState: UIControlState.Normal)
        
        if let visibleCells = self.profileTable?.visibleCells() {
            for cell in visibleCells {
                if var cell = cell as? UITableViewCell {
                    cell.backgroundColor = UIColor.whiteColor()
                    cell.textLabel?.textColor = UIColor.whiteColor()
                }
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let index: NSIndexPath = self.profileTable.indexPathForSelectedRow() {
            self.selectedProfile = self.fetchedResultsController.objectAtIndexPath(index) as NSManagedObject
            NSNotificationCenter.defaultCenter().postNotificationName(self.notificationKey, object: self, userInfo:["Index" : index, "Profile" : self.selectedProfile])
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.profileTable.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.profileTable.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.profileTable.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            profileTable.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            profileTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(profileTable.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            profileTable.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            profileTable.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.profileTable.endUpdates()
    }
    
}