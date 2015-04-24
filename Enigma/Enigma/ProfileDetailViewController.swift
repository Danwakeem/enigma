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
	var encryptions = NSOrderedSet()
	
	var encryptionList = [NSMutableDictionary]()
	
	// TODO: Impliment an edit buffer so that multiple encryptions can be handled
	var name: String = ""
	var cypher: String = "Cypher"
	var key1: String = ""
	
	var addButton: UIButton!
	
	var selectedCell: NSIndexPath!
	
	@IBAction func toggleEdit(sender: AnyObject) {
		setEditing(!editing, animated: true)
		self.addButton.hidden = !editing
	}
	
	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
		if editing == false {
			saveProfile()
		}
		collectionView!.reloadData()
		
		UIView.setAnimationsEnabled(animated)
		navigationItem.rightBarButtonItem?.title = editing ? "Save" : "Edit"
		navigationItem.rightBarButtonItem?.style = editing ? .Done : .Plain
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
		self.collectionView?.reloadData()
		
		let bounds = UIScreen.mainScreen().bounds
		
		let btn = UIButton()
		btn.frame = CGRectMake(bounds.width - 75, bounds.height - 135, 55, 55)
		btn.setTitle("+", forState: .Normal)
		btn.titleLabel?.font = UIFont.systemFontOfSize(28)
		btn.backgroundColor = UIColor(red: (52.0/255.0), green: (170.0/255.0), blue: (220.0/255.0), alpha: 1.0)
		btn.layer.cornerRadius = 27.5
		btn.addTarget(self, action: "addEncryption:", forControlEvents: .TouchUpInside)
		btn.contentVerticalAlignment = .Center
		self.view.addSubview(btn)
		self.view.bringSubviewToFront(btn)
		
		self.addButton = btn
		self.addButton.hidden = !editing
		
	}
	
	override func viewWillAppear(animated: Bool) {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(animated: Bool) {
		if editing == true {
			// Unsaved changes are lost
		}
		
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	override func viewDidLayoutSubviews() {
		var collectionViewLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
		collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		collectionViewLayout.itemSize = CGSizeMake(view.bounds.size.width - 40, 96)
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return encryptionList.count
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ProfileDetailCell
		
		cell.layer.borderColor = UIColor(white: 204.0/255.0, alpha: 1.0).CGColor
		cell.layer.borderWidth = 0.5
		
		var encryption = encryptionList[indexPath.row]
		
		cell.delegate = self
		cell.cypherButton.setTitle((encryption["encryptionType"] as! String), forState: UIControlState.Normal)
		cell.cypherButton.enabled = editing
		cell.keyField.text = encryption["key1"] as! String
		cell.keyField.enabled = editing
		
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var reusableView: UICollectionReusableView? = nil
		
		if kind == UICollectionElementKindSectionHeader {
			var headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! ProfileDetailHeaderView
			
			// set up profile data
			headerView.delegate = self
			headerView.profileNameField.text = name
			headerView.profileNameField.enabled = editing
			
			reusableView = headerView
		}
		
		return reusableView!
	}
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func validateProfile(errors: ([String]) -> Void) {
		var errorList = [String]()
		
		if count(name) == 0 {
			name = profile?.valueForKey("name") as! String
			errorList.append("name")
		}
		
		for encryption in encryptions {
			// TODO: validate
		}
		
		errors(errorList)
	}
	
	func saveProfile() {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		let newSet = NSMutableOrderedSet()
		for var i = 0; i < encryptionList.count; i++ {
			let encryptionEntity = NSEntityDescription.entityForName("Encryptions", inManagedObjectContext: managedContext)
			let encryption = NSManagedObject(entity: encryptionEntity!, insertIntoManagedObjectContext:managedContext)
			
			let dict = encryptionList[i]
			
			encryption.setValue(dict["encryptionType"], forKey: "encryptionType")
			encryption.setValue(dict["key1"], forKey: "key1")
			
			newSet.addObject(encryption)
			
		}
		
		if let existingProfile = profile {
			profile?.setValue(newSet, forKey: "encryption")
			profile?.setValue(self.name, forKey: "name")
		} else {
			let entity = NSEntityDescription.entityForName("Profiles", inManagedObjectContext: managedContext)
			let newProfile = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
			
			newProfile.setValue(self.name, forKey: "name")
			newProfile.setValue(newSet, forKey: "encryption")
		}
		
		/*validateProfile({ (errors) -> Void in
			var errorMessage: String
			
			if count(errors) == 1 {
				errorMessage = "The \(errors[0]) field is invalid."
			} else {
				errorMessage = "The following fields are invalid:\n"
				
				for (i, error) in enumerate(errors) {
					errorMessage += error
					if i < (count(errors) - 2) {
						errorMessage += ", "
					} else if i < (count(errors) - 1) {
						errorMessage += ", and "
					} else {
						errorMessage += "."
					}
				}
			}
			
			if count(errors) > 0 {
				var alert = UIAlertController(title: "Invalid Information", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
				return
			}
		})
		
		if let existingProfile = profile {
			existingProfile.setValue(name, forKey: "name")
			
			for encryption in encryptions {
				encryption.setValue(cypher, forKey: "encryptionType")
				encryption.setValue(key1, forKey: "key1")
			}
		} else {
			let entity = NSEntityDescription.entityForName("Profiles", inManagedObjectContext: managedContext)
			let newProfile = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
			let encryptionEntity = NSEntityDescription.entityForName("Encryptions", inManagedObjectContext: managedContext)
			let encryption = NSManagedObject(entity: encryptionEntity!, insertIntoManagedObjectContext:managedContext)
			
			newProfile.setValue("", forKey: "name")
			newProfile.setValue(NSDate(), forKey: "timestamp")
			
			encryption.setValue(cypher, forKey: "encryptionType")
			encryption.setValue(key1, forKey: "key1")
			encryption.setValue("", forKey: "key2")
			encryption.setValue(newProfile, forKey: "profiles")
			
			profile = newProfile
		}*/
		
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
	
	func cypherChanged(cell: ProfileDetailCell, key: String, value: String) {
		println("Cypher changed: \(key), \(value)")
		
		var index = self.collectionView?.indexPathForCell(cell)
		let dict = encryptionList[index!.row]
		
		
		dict.setValue(value, forKey: key)
		collectionView?.reloadData()
		
		if editing == false {
			setEditing(false, animated: true)
		}
	}
	
	func focusOnView(cell: ProfileDetailCell) {
		let index = self.collectionView?.indexPathForCell(cell)
		self.selectedCell = index
	}
	
	func nameSelected() {
		self.selectedCell = nil
	}
	
	func fetchEncryptions() {
		if profile == nil {
			return
		}
		
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		let fetchRequest = NSFetchRequest(entityName: "Encryptions")
		fetchRequest.predicate = NSPredicate(format: "ANY profiles == %@", profile!)
		
		var error: NSError?
		let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
		if let results = fetchedResults {
			encryptions = profile!.mutableOrderedSetValueForKey("encryption")
			
			// TODO: This will be removed once the edit buffer is implimented
			/*var first = encryptions[0] as! NSManagedObject
			cypher = first.valueForKey("encryptionType") as! String!
			key1 = first.valueForKey("key1") as! String!*/
			
			for var i = 0; i < encryptions.count; i++ {
				let dict = NSMutableDictionary()
				let encr = encryptions[i] as! NSManagedObject
				dict.setValue(encr.valueForKey("encryptionType"), forKey: "encryptionType")
				dict.setValue(encr.valueForKey("key1"), forKey: "key1")
				encryptionList.append(dict)
			}
			
		} else {
			println("Could not fetch \(error), \(error!.userInfo)")
		}
	}
	
	func addEncryption(sender: AnyObject) {
		let emptyCypher = NSMutableDictionary()
		emptyCypher.setValue("SimpleSub", forKey: "encryptionType")
		emptyCypher.setValue("", forKey: "key1")
		encryptionList.append(emptyCypher)
		self.collectionView?.reloadData()
	}
	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		switch segue.identifier! {
		case "showShare":
			var shareViewController = segue.destinationViewController as! ShareViewController
			shareViewController.profile = profile
		default:
			println("Default segue")
		}
	}
	
	// MARK: - Keyboard Notifications
	
	func keyboardWillShow(aNotification: NSNotification) {
		let info = aNotification.userInfo!
		let kbRect: CGRect = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
		let kbSize = kbRect.size as CGSize
		
		let newEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
		self.collectionView?.contentInset = newEdgeInsets
		
		if let cellIndex = self.selectedCell {
			self.collectionView?.scrollToItemAtIndexPath(cellIndex, atScrollPosition: .CenteredVertically, animated: true)
		}
	}
	
	func keyboardWillHide(aNotification: NSNotification) {
		let insets = UIEdgeInsetsZero
		self.collectionView?.contentInset = insets
		self.collectionView?.scrollIndicatorInsets = insets
	}
}
