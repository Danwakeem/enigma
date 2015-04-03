//
//  KeyboardViewController.swift
//  EnigmaKeyboard
//
//  Created by Dan jarvis on 1/23/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class KeyboardViewController: UIInputViewController, NSFetchedResultsControllerDelegate, KeyboardViewDelegate {
    
    var upperCase: Bool = false
    var caseLock: Bool = false
    var firstLetter: Bool = true
    var lastTypedWord: String = ""
    var proxy: UITextDocumentProxy!
    var managedObjectContext = CoreDataStack().managedObjectContext
    //EncryptionType to String
    var encryptionTypes = ["Caesar": Caesar, "Affine": Affine, "SimpleSub": SimpleSub, "Clear": Clear, "Vigenere": Vigenere]
    let notificationKey = "com.SlayterDev.selectedProfile"
    
    var currentProfile: NSManagedObject?
    var currentEncryptionMethods: Dictionary<String,[AnyObject]> = ["Caesar": ["13", "0"]]
    
    var height: NSLayoutConstraint!
    
    var Keyboard: KeyboardView = KeyboardView()
    var profileTable: ProfileTableView!
	
	var quickPeriodTimer: NSTimer!
	var allowQuickPeriod: Bool!
	
	var holdDeleteTimer: NSTimer!
	var preTimer: NSTimer!
	var deleteKey: UIButton!
	var isHoldingDelete: Bool! = false
	
	var defaults: NSUserDefaults!
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        // Add custom view sizing constraints here
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createKeyboard()
		
        
		// load defaults
		defaults = NSUserDefaults(suiteName: "group.com.enigma")
		allowQuickPeriod = false
		
        //self.view.backgroundColor = UIColor.whiteColor()
        
        self.proxy = textDocumentProxy as UITextDocumentProxy
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedProfile", name: self.notificationKey, object: nil)
        
        self.loadEncryptionFromUserDefaults()
        
        self.view.userInteractionEnabled = true
    }
    
    //MARK: - Set height 
    
    override func viewDidAppear(animated: Bool) {
        if UIInterfaceOrientationIsLandscape(self.interfaceOrientation) as Bool == true {
            let keyboardHeight = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 175)
            self.height = keyboardHeight
            self.view.addConstraint(keyboardHeight)
        } else {
            let keyboardHeight = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 275)
            self.height = keyboardHeight
            self.view.addConstraint(keyboardHeight)
        }
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) as Bool == true {
            self.view.removeConstraint(self.height)
            let keyboardHeight = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 175)
            self.height = keyboardHeight
            self.view.addConstraint(keyboardHeight)
        } else {
            self.view.removeConstraint(self.height)
            let keyboardHeight = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 275)
            self.height = keyboardHeight
            self.view.addConstraint(keyboardHeight)
        }
    }
    
    //MARK: - User default loading
    
    override func viewWillDisappear(animated: Bool) {
        //Save the encryption methods
        var keyArray = [String]()
        for (key,value) in self.currentEncryptionMethods {
            keyArray.append(key)
            self.defaults.setObject(value, forKey: key)
        }
        self.defaults.setObject(keyArray, forKey: "EncryptionDictionaryKeys")
        self.defaults.synchronize()
    }
    
    func loadEncryptionFromUserDefaults(){
        //Load up the most recent encryptionMethod from NSUserDefaults
        if let keys = self.defaults.arrayForKey("EncryptionDictionaryKeys") as? [String] {
            var encryptionMethods = Dictionary<String,[AnyObject]>()
            for key in keys {
                if let encryption = self.defaults.arrayForKey(key) {
                    encryptionMethods[key] = encryption
                }
            }
            self.currentEncryptionMethods = encryptionMethods
        }
    }
    
    //MARK: - Load Keyboard into view
    
    func createKeyboard(){
        self.Keyboard.delegate = self
        self.Keyboard.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(self.Keyboard)
        
        let left = NSLayoutConstraint(item: self.Keyboard, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: self.Keyboard, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: self.Keyboard, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.Keyboard, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        self.view.addConstraints([left,right,top,bottom])
    }
    
    //MARK: - Input text operations
	
	func playSound() {
		if defaults.boolForKey("TypingSounds") {
			AudioServicesPlaySystemSound(1104)
		}
	}
	
    func buttonTapped(sender: AnyObject) {
        let button = sender as UIButton
        
        if let title = button.titleForState(.Normal) {
            switch title {
            case "\u{232B}" :
                self.pressedBackSpace(title)
            case "rtn" :
                self.lastTypedWord = ""
                self.Keyboard.rawTextLabel.text = ""
                self.proxy.insertText("\n")
            case "space" :
                self.pressedSpace(title)
            case "\u{1f310}" :
                self.advanceToNextInputMode()
            case "\u{21E7}" :
                println(button.titleLabel?.font.description)
                self.upperCase = !self.upperCase
            case "123" :
                self.Keyboard.removeViews()
                self.Keyboard.createKeyboard([Keyboard.numberButtonTitles1,Keyboard.numberButtonTitles2,Keyboard.numberButtonTitles3,Keyboard.numberButtonTitles4])
            case "+#=":
                self.Keyboard.removeViews()
                self.Keyboard.createKeyboard([Keyboard.alternateKeyboardButtonTitles1,Keyboard.alternateKeyboardButtonTitles2,Keyboard.alternateKeyboardButtonTitles3,Keyboard.numberButtonTitles4])
            case "ABC" :
                self.Keyboard.removeViews()
                self.Keyboard.createKeyboard([Keyboard.buttonTitles1,Keyboard.buttonTitles2,Keyboard.buttonTitles3,Keyboard.buttonTitles4])
            case "👱":
                self.toggleProfileTable()
            default :
				if self.lastTypedWord == " " {
					self.lastTypedWord = ""
				}
                self.insertText(title)
            }
        }
		
		playSound()
    }
    
    func pressedBackSpace(title: String){
        self.proxy.deleteBackward()
        //Getting rid of the last typed word with input field
        if !self.lastTypedWord.isEmpty {
            //If last letter was uppercase then turn uppercase on for that ch
            var lastCh: String = self.lastTypedWord.lastPathComponent as String
            if lastCh.uppercaseString == lastCh {
                self.upperCase = true
            }
            self.lastTypedWord = self.lastTypedWord.substringToIndex(self.lastTypedWord.endIndex.predecessor())
        }
        
        self.Keyboard.rawTextLabel.text = self.lastTypedWord
        //self.rawTextLabel.text = self.lastTypedWord
		
		playSound()
    }
	
	func stopQuickPeriod() {
		println("Diallow quick period")
		allowQuickPeriod = false
	}
	
    func pressedSpace(title: String){
        
        self.Keyboard.rawTextLabel.text = ""
        //self.rawTextLabel.text = ""
        
        //This is where we would access self.lastTypedWord to encrypt their text.
        //Just use self.proxy.deleteBackward() to delete each char the user typed until it is gone then replace with the encrypted string.
        if self.lastTypedWord == " " && !self.proxy.documentContextBeforeInput.hasSuffix(". ") && allowQuickPeriod! && defaults!.boolForKey("QuickPeriod") {
            self.proxy.deleteBackward()
            self.proxy.insertText(". ")
            self.lastTypedWord = " "
			allowQuickPeriod = false
        } else {
            //Encryption test :)
            var encryptedString: String!
            
            for (key,value) in self.currentEncryptionMethods {
                var eType: EncryptionType = self.encryptionTypes[key]!
                var key1: String = value[0] as String
                var key2: Int32!
                var key2String: String = value[1] as String
                if let k2 = key2String.toInt() {
                    key2 = Int32(k2)
                }
                encryptedString = EncrytionFramework.encrypt(self.lastTypedWord, using: eType, withKey: key1, andKey: key2)
                //var encryptedString = EncrytionFramework.encrypt(self.lastTypedWord, using: Vigenere, withKey: "lemon", andKey: 0)
            }
            //var encryptedString = EncrytionFramework.encrypt(self.lastTypedWord, using: Caesar, withKey: "13", andKey: 0)
			
			if self.lastTypedWord != " " {
				allowQuickPeriod = true
			}
			
            self.proxy.insertText(encryptedString + " ")
            self.lastTypedWord = ""
			
			quickPeriodTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("stopQuickPeriod"), userInfo: nil, repeats: false)
        }
		
		playSound()
    }
        
    func insertText(title: String){
        if self.upperCase || self.caseLock || self.firstLetter {
            self.setRawTextlabelText(title)
            //self.proxy.insertText(title)
            self.lastTypedWord += title
            if self.upperCase {
                //Undo upercase so the next word wont be capitalized.
                self.upperCase = !self.upperCase
            } else if self.firstLetter {
                //Uncheck first letter so the next one wont be capitalized.
                self.firstLetter = !self.firstLetter
            }
        } else {
            //Adding a letter to the input and saving each letter so we know what the user just typed in
            self.setRawTextlabelText(title.lowercaseString)
            //self.proxy.insertText(title.lowercaseString)
            self.lastTypedWord += title.lowercaseString
        }
    }
    
    func setRawTextlabelText(title: String){
        if let notEmpty = self.Keyboard.rawTextLabel.text {
            self.Keyboard.rawTextLabel.text! += title
        } else {
            self.Keyboard.rawTextLabel.text = title
        }
    }
    
    func decryptPasteboard(){
        let pasteBoard = UIPasteboard.generalPasteboard()
        if let text = pasteBoard.string {
            self.Keyboard.decryptedTextLabel.text = self.decryptText(text)
            //self.decryptedTextLabel.text = self.decryptText(text)
        }
    }
    
    func decryptText(text: String) -> String{
        var returnString: String = text
        for (key,value) in self.currentEncryptionMethods {
            var eType: EncryptionType = self.encryptionTypes[key]!
            var key1: String = value[0] as String
            var key2: Int32!
            var key2String: String = value[1] as String
            if let k2 = key2String.toInt() {
                key2 = Int32(k2)
            }
            returnString = EncrytionFramework.decrypt(returnString, using: eType, withKey: key1, andKey: key2)
        }
        
        return returnString
    }
    
    func lockCase(sender: AnyObject) {
        self.caseLock = !self.caseLock
    }
    
    func longPressBackSpace(sender: AnyObject) {
        self.proxy.deleteBackward()
        self.Keyboard.rawTextLabel.text = ""
    }
	
	func deleteRelease() {
		isHoldingDelete = false
		if holdDeleteTimer != nil {
			holdDeleteTimer.invalidate()
		}
		preTimer.invalidate()
	}
	
	func deleteChar() {
		pressedBackSpace("\u{232B}")
	}
	
	func startTimer() {
		holdDeleteTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("deleteChar"), userInfo: nil, repeats: true)
	}
	
	func deleteHeld() {
		pressedBackSpace("\u{232B}")
		
		isHoldingDelete = true
		preTimer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: Selector("startTimer"), userInfo: nil, repeats: false)
	}
	
	func backSpaceTapped(sender: AnyObject) {
		deleteHeld()
	}
	
	func backSpaceReleased(sender: AnyObject) {
		deleteRelease()
	}
    
    //MARK: - Default UIInputView functions
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    override func textWillChange(textInput: UITextInput) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(textInput: UITextInput) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        var proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.Dark {
            textColor = UIColor.whiteColor()
        } else {
            textColor = UIColor.blackColor()
        }
    }
    
    //MARK: - Profile table
    
    func toggleProfileTable() {
        if self.profileTable == nil {
            if var profiles = self.createProfileTable() {
                profiles.hidden = true
                self.view.addSubview(profiles)
                self.profileTable = profiles
                profiles.setTranslatesAutoresizingMaskIntoConstraints(false)
                
                let widthConstraint = NSLayoutConstraint(item: profiles, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1.0, constant: 0)
                let heightConstraint = NSLayoutConstraint(item: profiles, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1.0, constant: 0)
                let centerXConstraint = NSLayoutConstraint(item: profiles, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0)
                let centerYConstraint = NSLayoutConstraint(item: profiles, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: 0)
                
                self.view.addConstraints([widthConstraint,heightConstraint,centerXConstraint,centerYConstraint])
            }
        }
        
        if let table = self.profileTable {
            let hidden = self.profileTable.hidden
            self.profileTable.hidden = !hidden
            self.Keyboard.encryptionRow.hidden = hidden
            self.Keyboard.row1.hidden = hidden
            self.Keyboard.row2.hidden = hidden
            self.Keyboard.row3.hidden = hidden
            self.Keyboard.row4.hidden = hidden
        }
    }
    
    func createProfileTable() -> ProfileTableView? {
        var profileTab = ProfileTableView()
        //Create an action for the cells
        for cell in profileTab.profileTable.visibleCells() as [UITableViewCell] {
            let alphaSelector: Selector = "selectedProfile"
            let singleTap = UITapGestureRecognizer(target: self, action: alphaSelector)
            singleTap.numberOfTapsRequired = 1
            cell.addGestureRecognizer(singleTap)
        }
        
        profileTab.backButton?.addTarget(self, action: Selector("toggleProfileTable"), forControlEvents: UIControlEvents.TouchUpInside)
        return profileTab
    }
    
    func selectedProfile(){
        self.currentProfile = self.profileTable.selectedProfile
        //getEncryptions isn't doing anything until the containing app saves the encryption keys with the profile
        self.getEncryptions()
        self.toggleProfileTable()
    }
    
    //Saving the selected EncryptionMethod
    func getEncryptions(){
        //Set the Encryption/Decryption Methods that is being used
        if let encryptions: NSOrderedSet = self.currentProfile?.mutableOrderedSetValueForKeyPath("encryption") {
            var newEncryptionMethods = Dictionary<String,[AnyObject]>()
            
            //NOTE: - NSOrderedSet conforms to sequence type as of Swift 1.2 (Xcode 6.3) but I have not updated yet and I didn't
            //        know if the rest of my team had either so I didn't want to mess anyone up. Not to mention I don't think Xcode 6.3
            //        is considered a stable build yet.
            encryptions.enumerateObjectsUsingBlock { (e, index, stop) -> Void in
                var encryptMethod = e.valueForKeyPath("encryptionType") as String!
                var key1 = e.valueForKeyPath("key1") as String!
                var key2 = "0"
                if let k2: String = e.valueForKeyPath("key2") as? String {
                    if k2 != "" {
                        key2 = k2
                    }
                }
                var keys = [key1,key2]
                newEncryptionMethods = [encryptMethod: keys]
            }
            self.currentEncryptionMethods = newEncryptionMethods
        }
    }
}