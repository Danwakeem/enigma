//
//  ProfileDetailViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class ProfileDetailViewController: UICollectionViewController, ProfileDetailHeaderViewDelegate, ProfileDetailCellDelegate {
	var profile: NSManagedObject? = nil
	var encryptions = [NSManagedObject]()
	
	// TODO: Impliment an edit buffer so that multiple encryptions can be handled
	var name: String = ""
	var cypher: String = ""
	var key1: String = ""
	
	@IBAction func toggleEdit(sender: AnyObject) {
		setEditing(!editing, animated: true)
	}
	
	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		if editing == false {
			saveProfile()
		}
		collectionView!.reloadData()
		
		UIView.setAnimationsEnabled(animated)
		navigationItem.rightBarButtonItem?.title = editing ? "Save" : "Edit"
		navigationItem.rightBarButtonItem?.style = editing ? .Done : .Plain;
		UIView.setAnimationsEnabled(true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		navigationItem.leftItemsSupplementBackButton = true
		
		if let profileName = profile?.valueForKey("name") as? String {
			name = profileName
		}
		fetchEncryptions()
	}
	
	override func viewDidLayoutSubviews() {
		var collectionViewLayout = collectionView?.collectionViewLayout as UICollectionViewFlowLayout
		collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		collectionViewLayout.itemSize = CGSizeMake(view.bounds.size.width - 40, 96)
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ProfileDetailCell
		
		cell.layer.borderColor = UIColor(white: 204.0/255.0, alpha: 1.0).CGColor
		cell.layer.borderWidth = 0.5
		
		var encryption = encryptions[indexPath.row]
		
		cell.delegate = self
		cell.cypherButton.setTitle(cypher, forState: .Normal)
		cell.cypherButton.enabled = editing
		cell.keyField.text = key1
		cell.keyField.enabled = editing
		
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var reusableView: UICollectionReusableView? = nil
		
		if kind == UICollectionElementKindSectionHeader {
			var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as ProfileDetailHeaderView
			
			// set up profile data
			headerView.delegate = self
			headerView.profileNameField.text = name
			headerView.profileNameField.enabled = editing
			
			reusableView = headerView
		}
		
		return reusableView!
	}
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return encryptions.count
	}
	
	func saveProfile() {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		profile?.setValue(name, forKey: "name")
		
		for encryption in encryptions {
			encryption.setValue(cypher, forKey: "encryptionType")
			encryption.setValue(key1, forKey: "key1")
            //Since we only have it saving one encryption type for now I am going to put this here just so we have a 
		}
		
		var error: NSError?
		if !managedContext.save(&error) {
			println("Could not save \(error), \(error?.userInfo)")
		}
		
		NSNotificationCenter.defaultCenter().postNotificationName("ProfileUpdated", object: profile)
	}
	
	func profileNameChanged(name: String) {
		self.name = name
		
		if editing == false {
			setEditing(false, animated: true)
		}
	}
	
	func cypherChanged(key: String, value: String) {
		if key == "key1" {
			self.key1 = value
		} else {
			self.cypher = value
			collectionView?.reloadData()
		}
		
		if editing == false {
			setEditing(false, animated: true)
		}
	}
	
	func fetchEncryptions() {
		if profile == nil {
			return
		}
		
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		let fetchRequest = NSFetchRequest(entityName: "Encryptions")
		fetchRequest.predicate = NSPredicate(format: "ANY profiles == %@", profile!)
		
		var error: NSError?
		let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
		if let results = fetchedResults {
			encryptions = results
			
			// TODO: This will be removed once the edit buffer is implimented
			var first = encryptions[0]
			cypher = first.valueForKey("encryptionType") as String!
			key1 = first.valueForKey("key1") as String!
		} else {
			println("Could not fetch \(error), \(error!.userInfo)")
		}
	}
}
