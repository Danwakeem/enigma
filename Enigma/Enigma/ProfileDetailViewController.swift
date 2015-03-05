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
	var encryptionMethods = [ "Affine", "Ceasar" ]
	
	@IBAction func toggleEdit(sender: AnyObject) {
		setEditing(!editing, animated: true)
	}
	
	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		collectionView!.reloadData()
		
		UIView.setAnimationsEnabled(animated)
		navigationItem.rightBarButtonItem?.title = editing ? "Save" : "Edit"
		navigationItem.rightBarButtonItem?.style = editing ? .Done : .Plain;
		UIView.setAnimationsEnabled(true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var collectionViewLayout = collectionView?.collectionViewLayout as UICollectionViewFlowLayout
		collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		
		navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		navigationItem.leftItemsSupplementBackButton = true
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as ProfileDetailCell
		
		cell.layer.borderColor = UIColor(white: 204.0/255.0, alpha: 1.0).CGColor
		cell.layer.borderWidth = 0.5
		
		cell.delegate = self
		cell.cypherButton.setTitle("Caesar", forState: .Normal)
		cell.cypherButton.enabled = editing
		cell.keyField.text = "123"
		cell.keyField.enabled = editing
		
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var reusableView: UICollectionReusableView? = nil
		
		if kind == UICollectionElementKindSectionHeader {
			var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as ProfileDetailHeaderView
			
			// set up profile data
			headerView.delegate = self
			headerView.profileNameField.text = profile?.valueForKey("name") as String!
			headerView.profileNameField.enabled = editing
			
			reusableView = headerView
		}
		
		return reusableView!
	}
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func profileNameChanged(name: String) {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		profile?.setValue(name, forKey: "name")
		
		var error: NSError?
		if !managedContext.save(&error) {
			println("Could not save \(error), \(error?.userInfo)")
		}
		
		NSNotificationCenter.defaultCenter().postNotificationName("ProfileUpdated", object: profile)
	}
	
	func cypherChanged(cypher: String, key1: String, key2: String) {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		
	}
}
