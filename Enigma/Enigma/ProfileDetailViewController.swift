//
//  ProfileDetailViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class ProfileDetailViewController: UICollectionViewController, ProfileDetailHeaderViewDelegate, ProfileDetailCellDelegate, EncryptDecryptPopupViewDelegate {
	var profile: NSManagedObject? = nil
	var encryptions = NSOrderedSet()
	
	var encryptionList = [NSMutableDictionary]()
    
    var encryptDecryptPopup: EncryptDecryptPopupView?
    
    var encryptionTypes = ["Caesar": Caesar, "Affine": Affine, "SimpleSub": SimpleSub, "Clear": Clear, "Vigenere": Vigenere, "Cypher": Clear]
    var randomWords = ["iPhone", "yolo", "blacksheep", "gettothechoppa", "thosearntmountains", "crabs", "zebra", "clowns", "jamesbond", "whoppers", "skittles", "android", "coolkid", "icecream", "clubsandwhich", "racata", "mountain", "legs", "keyboard", "alphabet", "young", "england", "america"]
	
	// TODO: Impliment an edit buffer so that multiple encryptions can be handled
	var name: String = ""
	var cypher: String = "Cypher"
	var key1: String = ""
    
    var key1Buffer = ""
	
	var addButton: AddEncryptionButton!
	
	var selectedCell: NSIndexPath!
	
	@IBAction func toggleEdit(sender: AnyObject) {
		if count(name) == 0 {
			UIAlertView(title: "Error", message: "Profile must have a name!", delegate: nil, cancelButtonTitle: "Ok")
			return
		}
		
		if encryptionList.count == 0 {
			UIAlertView(title: "Error", message: "You must have at least one encryption type!", delegate: nil, cancelButtonTitle: "Ok").show()
			return
		}

		setEditing(!editing, animated: true)
	}
	
	override func setEditing(editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		
        if self.addButton != nil {
            self.addButton.hidden = !editing
        }
		
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
		
		let btn = AddEncryptionButton()
		btn.frame = CGRectMake(bounds.width - 75, bounds.height - 135, 55, 55)
		
		if UI_USER_INTERFACE_IDIOM() == .Pad {
			btn.frame = CGRectMake(self.view.center.x - 500, self.view.center.y + 240, 55, 55)
		}
		
        btn.addTarget(self, action: "changeButtonColor", forControlEvents: .TouchDown)
        btn.addTarget(self, action: "addEncryption:", forControlEvents: .TouchUpInside)
		self.view.addSubview(btn)
		self.view.bringSubviewToFront(btn)
		
		self.addButton = btn
		self.addButton.hidden = !editing
		
	}
    
    func changeButtonColor(){
        self.addButton.bgColor = UIColor(red: 0.188, green:0.514, blue:0.682, alpha:1)
        self.addButton.setNeedsDisplay()
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width = UIScreen.mainScreen().bounds.width / 1.06
        if UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height {
            width = UIScreen.mainScreen().bounds.width / 1.7
        }
        
        var encryptionType = encryptionList[indexPath.row]
        if encryptionType.valueForKey("encryptionType")?.description == "Affine" {
            return CGSizeMake(UIScreen.mainScreen().bounds.width / 1.06, 200)
        }
        return CGSizeMake(width, 155)
    }
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ProfileDetailCell
        
		cell.layer.borderColor = UIColor(white: 204.0/255.0, alpha: 1.0).CGColor
		cell.layer.borderWidth = 0.5
		
		var encryption = encryptionList[indexPath.row]
		
		cell.delegate = self
        
        cell.cypherSelection.enabled = editing
		cell.helpLabel.text = EncrytionFramework.helpStringForEncryptionType(encryption["encryptionType"] as! String)
		cell.deleteButton.hidden = !editing
		cell.keyField.text = encryption["key1"] as! String
		cell.keyField.enabled = editing
        cell.key2Label.hidden = true
        cell.key2Field.hidden = true
        
        let title = encryption["encryptionType"] as! String!
        switch title {
        case "SimpleSub":
            cell.cypherSelection.selectedSegmentIndex = 1
        case "Caesar":
            cell.cypherSelection.selectedSegmentIndex = 0
        case "Vigenere":
            cell.cypherSelection.selectedSegmentIndex = 2
        default:
            cell.cypherSelection.selectedSegmentIndex = 3
            cell.key2Label.hidden = false
            cell.key2Field.hidden = false
            if encryption["key2"] != nil {
                cell.key2Field.text = encryption["key2"] as! String
            }
            cell.key2Field.enabled = editing
        }
		
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
		
        key1Buffer = ""
        
		return reusableView!
	}
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
    
    func encryptPopup(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        encryptDecryptPopup = sb.instantiateViewControllerWithIdentifier("EncryptDecryptPopupView") as? EncryptDecryptPopupView
        encryptDecryptPopup?.delegate = self
        encryptDecryptPopup?.popupType = .Encrypt
        encryptDecryptPopup?.modalTransitionStyle = .CoverVertical
        encryptDecryptPopup?.modalPresentationStyle = .OverFullScreen
        encryptDecryptPopup?.preferredContentSize = CGSize(width:self.view.frame.width * CGFloat(1 / 100.0), height:self.view.frame.height * CGFloat(1 / 100.0))
        presentViewController(encryptDecryptPopup!, animated: true, completion: {})
    }
    
    func decryptPopup(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        encryptDecryptPopup = sb.instantiateViewControllerWithIdentifier("EncryptDecryptPopupView") as? EncryptDecryptPopupView
        encryptDecryptPopup?.delegate = self
        encryptDecryptPopup?.popupType = .Decrypt
        encryptDecryptPopup?.modalTransitionStyle = .CoverVertical
        encryptDecryptPopup?.modalPresentationStyle = .OverFullScreen
        encryptDecryptPopup?.preferredContentSize = CGSize(width:self.view.frame.width * CGFloat(1 / 100.0), height:self.view.frame.height * CGFloat(1 / 100.0))
        presentViewController(encryptDecryptPopup!, animated: true, completion: {})
        
    }
    
    func sendTextToDelegate(string: String) {
        let  char = string.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            if key1Buffer != "" {
                key1Buffer = key1Buffer.substringWithRange(Range<String.Index>(start: key1Buffer.startIndex, end: key1Buffer.endIndex.predecessor()))
            }
        } else if key1Buffer == "" {
            key1Buffer = string
        } else {
            key1Buffer += string
        }
    }
    
    func closePop(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    func decryptText(text: String) {
        var decryptString: String = text
        for encryption in encryptions.reversedOrderedSet {
            let enManaged = encryption as! NSManagedObject
            let eType: String = enManaged.valueForKeyPath("encryptionType") as! String!
            let key1: String = enManaged.valueForKeyPath("key1") as! String!
            var key2: Int = 0
            if let k2: String = enManaged.valueForKeyPath("key2") as? String {
                if k2 != "" {
                    key2 = k2.toInt()!
                }
            }
            decryptString = EncrytionFramework.decrypt(decryptString, using: encryptionTypes[eType]!, withKey: key1, andKey: Int32(key2))
        }
        encryptDecryptPopup?.showDecryptedString(decryptString)
    }
    
    func encryptString(lastTypedWord: String) {
        var encryptedString: String = lastTypedWord
        for encryption in encryptions {
            let enManaged = encryption as! NSManagedObject
            let eType: String = enManaged.valueForKeyPath("encryptionType") as! String!
            let key1: String = enManaged.valueForKeyPath("key1") as! String!
            var key2: Int = 0
            if let k2: String = enManaged.valueForKeyPath("key2") as? String {
                if k2 != "" {
                    key2 = k2.toInt()!
                }
            }
            encryptedString = EncrytionFramework.encrypt(encryptedString, using: encryptionTypes[eType]!, withKey: key1, andKey: Int32(key2))
        }
        encryptDecryptPopup?.addEncryptedString(encryptedString)
    }
	
	func validateProfile(errors: ([String]) -> Void) {
		var errorList = [String]()
		
		if count(name) == 0 {
			if let nameVal = profile?.valueForKey("name") as? String {
				name = profile?.valueForKey("name") as! String
			}
			errorList.append("name")
		}
		
		for encryption in encryptionList {
			let key = encryption.valueForKey("key1") as! String
            var key2 = ""
            if var value = encryption.valueForKey("key2") as? String{
                key2 = value
                if key2 == "" {
                    errorList.append(encryption.valueForKey("encryptionType") as! String)
                }
            }
			println(key)
			if key == "" {
                if key1Buffer != "" {
                    encryption.setValue(key1Buffer, forKey: "key1")
                } else {
                    errorList.append(encryption.valueForKey("encryptionType") as! String)
                }
            }
			
			let type = EncrytionFramework.encryptionTypeForString(encryption["encryptionType"] as! String)
			if EncrytionFramework.validateKeyWithKey(encryption["key1"] as! String, type: type, andKeyNumber: 1) == false {
				errorList.append(encryption["encryptionType"] as! String)
			}
		}
		
		errors(errorList)
	}
	
	func saveProfile() -> Void {
		let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		
		var didError = false
		validateProfile({ (errors) -> Void in
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
				
				self.setEditing(true, animated: true)
				
				didError = true
			}
		})
		
		if didError == true {
			self.setEditing(true, animated: false)
			self.navigationItem.rightBarButtonItem?.title = "Save"
			self.navigationItem.rightBarButtonItem?.style = .Done
			println("WTTTTTFFFFFFFFFFFFF")
			return
		}
		
		println("Still saving")
		
		let newSet = NSMutableOrderedSet()
		for var i = 0; i < encryptionList.count; i++ {
			let encryptionEntity = NSEntityDescription.entityForName("Encryptions", inManagedObjectContext: managedContext)
			let encryption = NSManagedObject(entity: encryptionEntity!, insertIntoManagedObjectContext:managedContext)
			
			let dict = encryptionList[i]
			
			encryption.setValue(dict["encryptionType"], forKey: "encryptionType")
			encryption.setValue((dict["key1"] as! String).stringByReplacingOccurrencesOfString(" ", withString: ""), forKey: "key1")
            if let value = dict["key2"] as? String {
                encryption.setValue(value, forKey: "key2")
            }
			
			newSet.addObject(encryption)
			
		}
        
        encryptions = newSet
		
		if let existingProfile = profile {
			profile?.setValue(newSet, forKey: "encryption")
			profile?.setValue(self.name, forKey: "name")
		} else {
			let entity = NSEntityDescription.entityForName("Profiles", inManagedObjectContext: managedContext)
			let newProfile = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
			
			newProfile.setValue(self.name, forKey: "name")
			newProfile.setValue(newSet, forKey: "encryption")
			profile = newProfile
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
	
	func deleteEncryptionType(cell: ProfileDetailCell) {
		let index = self.collectionView?.indexPathForCell(cell)?.row
		
		encryptionList.removeAtIndex(index!)
		self.collectionView?.reloadData()
	}
	
	func focusOnView(cell: ProfileDetailCell) {
		let index = self.collectionView?.indexPathForCell(cell)
		self.selectedCell = index
	}
	
	func nameSelected() {
		self.selectedCell = nil
	}
    
    func generateCyphers(){
        var numberOfEncryptions = arc4random_uniform(5) + 1
        println(numberOfEncryptions)
        for(var i: UInt32 = 0; i <= numberOfEncryptions; i++) {
            let dict = NSMutableDictionary()
            switch(i % 4) {
            case 0:
                var randomKey = arc4random_uniform(UInt32(randomWords.count))
                var randomWord = randomWords[Int(randomKey)]
                dict.setValue("SimpleSub", forKey: "encryptionType")
                dict.setValue(randomWord, forKey: "key1")
            case 1:
                var randomKey = arc4random_uniform(26) + 1
                dict.setValue("Caesar", forKey: "encryptionType")
                dict.setValue(randomKey.description as String, forKey: "key1")
            case 2:
                var randomKey = arc4random_uniform(UInt32(randomWords.count))
                var randomWord = randomWords[Int(randomKey)]
                dict.setValue("Vigenere", forKey: "encryptionType")
                dict.setValue(randomWord, forKey: "key1")
            default:
                var randomKey = arc4random_uniform(25)
                if randomKey % 2 == 0 {
                    randomKey += 1
                }
                var randomKey2 = arc4random_uniform(25)
                dict.setValue("Affine", forKey: "encryptionType")
                dict.setValue(randomKey.description, forKey: "key1")
                dict.setValue(randomKey2.description, forKey: "key2")
            }
            encryptionList.append(dict)
        }
    }
	
	func fetchEncryptions() {
		if profile == nil {
            if NSUserDefaults(suiteName: "group.com.enigma")?.boolForKey("AutoCypher") == true {
                generateCyphers()
            }
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
                if let value = encr.valueForKey("key2")?.description {
                    dict.setValue(value, forKey: "key2")
                }
				encryptionList.append(dict)
			}
			
		} else {
			println("Could not fetch \(error), \(error!.userInfo)")
		}
	}
	
	func addEncryption(sender: AnyObject) {
        self.addButton.bgColor = UIColor(red: 0.172, green: 0.6, blue: 0.827, alpha: 1)
        self.addButton.setNeedsDisplay()
        
		let emptyCypher = NSMutableDictionary()
		emptyCypher.setValue("SimpleSub", forKey: "encryptionType")
		emptyCypher.setValue("", forKey: "key1")
		encryptionList.append(emptyCypher)
		self.collectionView?.reloadData()
        key1Buffer = ""
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
