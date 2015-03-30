//
//  KeyboardViewController.swift
//  EnigmaKeyboard
//
//  Created by Dan jarvis on 1/23/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class KeyboardViewController: UIInputViewController, NSFetchedResultsControllerDelegate {
    
    var upperCase: Bool = false
    var caseLock: Bool = false
    var firstLetter: Bool = true
    var lastTypedWord: String = ""
    var proxy: UITextDocumentProxy!
    
    var managedObjectContext = CoreDataStack().managedObjectContext
    
    //EncryptionType to String
    var encryptionTypes = ["Caesar": Caesar, "Affine": Affine, "SimpleSub": SimpleSub, "Clear": Clear, "Vigenere": Vigenere]
    
    //21ea == uppercase
    //1f310 == Globe
    let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
    let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
    let buttonTitles3 = ["\u{21E7}", "Z", "X", "C", "V", "B", "N", "M", "\u{232B}"]
    let buttonTitles4 = ["123", "👱", "\u{1f310}", "space", "rtn"]
    
    let numberButtonTitles1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    let numberButtonTitles2 = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
    let numberButtonTitles3 = ["+#=", ".", ",", "?", "!", "'", "\u{232B}"]
    let numberButtonTitles4 = ["ABC", "👱", "\u{1f310}", "space", "rtn"]
    
    let alternateKeyboardButtonTitles1 = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]
    let alternateKeyboardButtonTitles2 = ["_", "\\", "|", "~", "<", ">", "¢", "£", "¥", "•"]
    let alternateKeyboardButtonTitles3 = ["123", ".", ",", "?", "!", "'", "\u{232B}"]
    
    var encryptionRow: UIView!
    var row1: UIView!
    var row2: UIView!
    var row3: UIView!
    var row4: UIView!
    var decryptionDirectionsView: UIView!
    var decryptionTextView: UIView!
    var decryptionView: UIView!
    var rowHeight: CGFloat!
    
    var decryptionTopConstraint: NSLayoutConstraint!
    var decryptionBottomConstraint: NSLayoutConstraint!
    var decryptionLeftConstraint: NSLayoutConstraint!
    var decryptionRightConstraint: NSLayoutConstraint!
    
    let rawTextLabel: UILabel = UILabel(frame: CGRectMake(0, 0, 350, 50))
    let toggleEncryptDecrypt: UIButton = UIButton()
    let decryptButton: UIButton = UIButton()
    let decryptedTextLabel: UILabel = UILabel(frame: CGRectMake(0, 0, 350, 50))
    
    var row0Con: NSLayoutConstraint!
    var row1Con: NSLayoutConstraint!
    var row2Con: NSLayoutConstraint!
    var row3Con: NSLayoutConstraint!
    var row4Con: NSLayoutConstraint!
    var row4ConBottom: NSLayoutConstraint!
    
    let notificationKey = "com.SlayterDev.selectedProfile"
    
    var currentProfile: NSManagedObject!
    var currentEncryptionMethods: Dictionary<String,[AnyObject]> = ["Caesar": ["13", "0"]]
    
    var profileTable: ProfileTableView!
	
	var quickPeriodTimer: NSTimer!
	var allowQuickPeriod: Bool!
	
	var defaults: NSUserDefaults!
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// load defaults
		defaults = NSUserDefaults(suiteName: "group.com.enigma")
		allowQuickPeriod = false
		
        //self.view.backgroundColor = UIColor.whiteColor()
        self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        self.proxy = textDocumentProxy as UITextDocumentProxy
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectedProfile", name: self.notificationKey, object: nil)

        //Load up the most recent encryptionMethod from NSUserDefaults
        
        let alphaSelector: Selector = "toggleAlphaKeyboard:"
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: alphaSelector)
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        rightSwipe.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(rightSwipe)
        
        
        let numberSelector: Selector = "toggleNumberKeyboard:"
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: numberSelector)
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        leftSwipe.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(leftSwipe)
        
        self.view.userInteractionEnabled = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let keyboardHeight = NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 275)
        self.view.addConstraint(keyboardHeight)
    }
    
    /* Keyboard functions */
    
    func toggleAlphaKeyboard(sender: UISwipeGestureRecognizer) {
        self.removeViews()
        self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
    }
    
    func toggleNumberKeyboard(sender: UISwipeGestureRecognizer) {
        self.removeViews()
        self.createKeyboard([numberButtonTitles1,numberButtonTitles2,numberButtonTitles3,numberButtonTitles4])
    }
    
    func lockCase(sender: AnyObject?) {
        self.caseLock = !self.caseLock
    }
    
    func longPressBackSpace(sender: AnyObject) {
        self.proxy.deleteBackward()
        self.rawTextLabel.text = ""
    }
    
    func buttonTapped(sender: AnyObject?) {
        let button = sender as UIButton
        
        if let title = button.titleForState(.Normal) {
            switch title {
            case "\u{232B}" :
                self.pressedBackSpace(title)
            case "rtn" :
                self.lastTypedWord = ""
                self.rawTextLabel.text = ""
                self.proxy.insertText("\n")
            case "space" :
                self.pressedSpace(title)
            case "\u{1f310}" :
                self.advanceToNextInputMode()
            case "\u{21E7}" :
                self.upperCase = !self.upperCase
            case "123" :
                self.removeViews()
                self.createKeyboard([numberButtonTitles1,numberButtonTitles2,numberButtonTitles3,numberButtonTitles4])
            case "+#=":
                self.removeViews()
                self.createKeyboard([alternateKeyboardButtonTitles1,alternateKeyboardButtonTitles2,alternateKeyboardButtonTitles3,numberButtonTitles4])
            case "ABC" :
                self.removeViews()
                self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
            case "👱":
                self.toggleProfileTable()
            default :
                self.insertText(title)
            }
        }
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
        self.rawTextLabel.text = self.lastTypedWord
    }
	
	func stopQuickPeriod() {
		println("Diallow quick period")
		allowQuickPeriod = false
	}
	
    func pressedSpace(title: String){
        self.rawTextLabel.text = ""
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
            self.lastTypedWord = " "
			
			quickPeriodTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("stopQuickPeriod"), userInfo: nil, repeats: false)
        }
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
        if let notEmpty = self.rawTextLabel.text {
            self.rawTextLabel.text! += title
        } else {
            self.rawTextLabel.text = title
        }
    }
    
    func removeGestures(){
        for gesture in self.view.gestureRecognizers as [UIGestureRecognizer] {
            self.view.removeGestureRecognizer(gesture)
        }
    }
    
    func toggleCryption(){
        if self.toggleEncryptDecrypt.titleForState(.Normal) == "E" {
            self.toggleEncryptDecrypt.setTitle("D", forState: .Normal)
            let frame = self.encryptionRow.frame
            self.rowHeight = frame.height
            self.setUpDecryptionView()
            self.animateDecryptionViewIn()
            self.removeGestures()
        } else {
            self.animateDecryptionViewOut()
            self.toggleEncryptDecrypt.setTitle("E", forState: .Normal)
        }
    }
    
    func animateDecryptionViewIn(){
        var newBottomConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        //var row1Con = NSLayoutConstraint(item: self.row1, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        //var row2Con = NSLayoutConstraint(item: self.row2, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        //var row3Con = NSLayoutConstraint(item: self.row3, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        //var row4Con = NSLayoutConstraint(item: self.row4, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut , animations: {
            /*
            self.view.removeConstraints([self.row0Con,self.row4ConBottom])
            self.view.addConstraint(row1Con)
            self.view.layoutIfNeeded()
            */

            self.view.removeConstraint(self.decryptionBottomConstraint)
            self.view.addConstraint(newBottomConstraint)
            self.view.layoutIfNeeded()

            
            }, completion: nil)
        
        /*
        self.row0Con = row1Con
        let alphaSelector: Selector = "toggleCryption"
        let upSwipe = UISwipeGestureRecognizer(target: self, action: alphaSelector)
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        upSwipe.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(upSwipe)
        
        self.row1Con = row2Con
        self.row2Con = row3Con
        self.row3Con = row4Con
        */

        self.decryptionBottomConstraint = newBottomConstraint
    }
    
    
    //Try removing the constraints then calling add constraintstoinputview
    func animateDecryptionViewOut(){
        var newBottomConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -200)
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn , animations: {
            self.view.removeConstraint(self.decryptionBottomConstraint)
            self.view.addConstraint(newBottomConstraint)
            self.view.layoutIfNeeded()
            }, completion: {(complete: Bool) -> Void in
                self.view.removeConstraint(self.row0Con)
                //self.view.removeConstraints([self.row0Con,self.row1Con,self.row2Con,self.row3Con,self.row4Con])
                //self.addConstraintsToInputView(self.view, rowViews: [self.encryptionRow, self.row1, self.row2, self.row3, self.row4])
                
                self.decryptionView.removeFromSuperview()
                self.decryptionDirectionsView.removeFromSuperview()
                self.decryptionTextView.removeFromSuperview()
                self.decryptedTextLabel.removeFromSuperview()
                self.decryptButton.removeFromSuperview()
            })
        
        self.decryptionBottomConstraint = newBottomConstraint
    }
    
    func decryptPasteboard(){
        let pasteBoard = UIPasteboard.generalPasteboard()
        if let text = pasteBoard.string {
            self.decryptedTextLabel.text = self.decryptText(text)
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
    
    func removeViews(){
        for theView in self.view.subviews {
            theView.removeFromSuperview()
        }
    }
    
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
    
    func toggleProfileTable() {
        if self.profileTable == nil {
            if var profiles = self.createProfileTable() {
                profiles.hidden = true
                self.view.addSubview(profiles)
                self.profileTable = profiles
                
                profiles.setTranslatesAutoresizingMaskIntoConstraints(false)
                
                let widthConstraint = NSLayoutConstraint(item: profiles, attribute: .Width, relatedBy: .Equal, toItem: self.view, attribute: .Width, multiplier: 1, constant: 0)
                let heightConstraint = NSLayoutConstraint(item: profiles, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 1, constant: 0)
                let centerXConstraint = NSLayoutConstraint(item: profiles, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0)
                let centerYConstraint = NSLayoutConstraint(item: profiles, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0)
                
                self.view.addConstraints([widthConstraint,heightConstraint,centerXConstraint,centerYConstraint])
            }
        }
        
        if let table = self.profileTable {
            let hidden = self.profileTable.hidden
            table.hidden = !hidden
            self.encryptionRow.hidden = hidden
            self.row1.hidden = hidden
            self.row2.hidden = hidden
            self.row3.hidden = hidden
            self.row4.hidden = hidden
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
        //This method isnt doing anything until the containing app saves the encryption keys with the profile
        self.getEncryptions()
        self.toggleProfileTable()
    }
    
    //Saving the selected EncryptionMethod
    func getEncryptions(){
        //Set the Encryption/Decryption Methods that is being used
        if let encryptions: NSSet = self.currentProfile?.mutableSetValueForKeyPath("encryption") {
            var newEncryptionMethods = Dictionary<String,[AnyObject]>()
            
            //self.currentEncryptionMethods = Dictionary<String,[AnyObject]>()
            
            for (index, e) in enumerate(encryptions) {
                var encryptMethod = e.valueForKeyPath("encryptionType") as String!
                self.proxy.insertText(encryptMethod + " ")
                var key1 = e.valueForKeyPath("key1") as String!
                self.proxy.insertText(key1 + " ")
                var key2: String!
                if let k2: String = e.valueForKeyPath("key2") as? String {
                    key2 = k2
                } else {
                    key2 = "0"
                }
                self.proxy.insertText(key2 + " ")
                var keys = [key1,key2]
                newEncryptionMethods = [encryptMethod: keys]
                self.currentEncryptionMethods = newEncryptionMethods
            }
        } else {
            println("I know this doesnt actually print to the console but YOLO")
        }
    }
    
    /* Keyboard setup */
    
    func createKeyboard(buttonTitles: [AnyObject]){
        //Row of buttons as a view. Example "qwertyuiop"
        //self.encryptionRow = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
        //self.encryptionRow.frame = CGRectMake(0, 0, 320, 50)
        
        self.encryptionRow = UIView(frame: CGRectMake(0, 0, 320, 50))
        //self.encryptionRow.backgroundColor = UIColor(red: 0.388, green: 0.388, blue: 0.388, alpha: 0.2)
        self.encryptionRow.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.945, alpha: 1.0)
        
        self.row1 = rowOfButtons(buttonTitles[0] as [String])
        self.row2 = rowOfButtons(buttonTitles[1] as [String])
        self.row3 = rowOfButtons(buttonTitles[2] as [String])
        self.row4 = rowOfButtons(buttonTitles[3] as [String])

        self.createEncryptDecryptToggleButton()
        
        //add the views of button arrays to the screen
        self.encryptionRow.addSubview(self.rawTextLabel)
        self.rawTextLabel.addSubview(self.toggleEncryptDecrypt)
        self.view.addSubview(encryptionRow)
        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)
        
        let alphaSelector: Selector = "toggleCryption"
        let downSwipe = UISwipeGestureRecognizer(target: self, action: alphaSelector)
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        downSwipe.numberOfTouchesRequired = 1
        self.encryptionRow.addGestureRecognizer(downSwipe)
        
        //Disable all of the autolayout stuff that gets automatically set by adding a subview that way
        //we can add our own autolayout attributes
        self.encryptionRow.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.row4.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.rawTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Adding the constraints to the rows of keys. I took these constraints from the tutorial I followed
        addConstraintsToInputView(self.view, rowViews: [self.encryptionRow, self.row1, self.row2, self.row3, self.row4])
        
        //Add the constraints rawTextView to the encryptionRow
        constraintsForRawTextLabel()
        //Center the text in the label
        self.rawTextLabel.textAlignment = .Center
    }
    
    func createDecryptButton(){
        self.decryptButton.setTitle("Decrypt pasteboard", forState: .Normal)
        self.decryptButton.frame = CGRectMake(0, 0, 320, 50)
        self.decryptButton.clipsToBounds = true
        self.decryptButton.sizeToFit()
        self.decryptButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.decryptButton.backgroundColor = UIColor.clearColor()
        self.decryptButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        self.decryptButton.addTarget(self, action: "decryptPasteboard", forControlEvents: .TouchUpInside)
        self.decryptButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    func createEncryptDecryptToggleButton(){
        //So the button is clickable
        self.encryptionRow.userInteractionEnabled = true
        self.rawTextLabel.userInteractionEnabled = true
        
        //Change to a D when you are in decrypt mode
        self.toggleEncryptDecrypt.setTitle("E", forState: .Normal)
        self.toggleEncryptDecrypt.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        self.toggleEncryptDecrypt.frame = CGRectMake(0, 0, 50, 50)
        self.toggleEncryptDecrypt.clipsToBounds = true
        self.toggleEncryptDecrypt.sizeToFit()
        self.toggleEncryptDecrypt.titleLabel?.font = UIFont.systemFontOfSize(15)
        //self.toggleEncryptDecrypt.backgroundColor = UIColor(red: 0.251, green: 0.251, blue: 0.251, alpha: 0.2)
        self.toggleEncryptDecrypt.backgroundColor = UIColor(red: 0.91, green: 0.902, blue: 0.902, alpha: 1.0)
        self.toggleEncryptDecrypt.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        self.toggleEncryptDecrypt.addTarget(self, action: "toggleCryption", forControlEvents: .TouchUpInside)
        self.toggleEncryptDecrypt.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    //Create the rows of buttons
    func rowOfButtons(buttonTitles: [NSString]) -> UIView {
        //Array of buttons that will go in the row
        var buttons = [UIButton]()
        //Setting up the size of the array of keys
        var keyboardRowView = UIView(frame: CGRectMake(0, 0, 320, 50))
        //Create each button in the row
        for buttonTitle in buttonTitles{
            let button = createButtonWithTitle(buttonTitle)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        //Adding the constraints for each button in the row.
        if(buttons[2].titleForState(.Normal) == "\u{1f310}"){
            addBottomRowConstraints(buttons, mainView: keyboardRowView)
        } else {
            addIndividualButtonConstraints(buttons, mainView: keyboardRowView)
        }
        
        return keyboardRowView
    }
    
    //Creating a button with the title from the button* arrays
    func createButtonWithTitle(title: String) -> UIButton {
        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRectMake(0, 0, 20, 20)
        button.clipsToBounds = true
        button.setTitle(title, forState: .Normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFontOfSize(20)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        
        let singleTap = UITapGestureRecognizer(target: self, action: "buttonTapped:")
        singleTap.numberOfTapsRequired = 1
        button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        
        if title == "\u{21E7}" {
            button.backgroundColor = UIColor.lightGrayColor()
            button.layer.opacity = 0.5
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
            let doubleTap = UITapGestureRecognizer(target: self, action: "lockCase:")
            doubleTap.numberOfTapsRequired = 2
            button.addGestureRecognizer(doubleTap)
            singleTap.requireGestureRecognizerToFail(doubleTap)
        } else if title == "\u{232B}" {
            button.backgroundColor = UIColor.lightGrayColor()
            button.layer.opacity = 0.5
            //button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
            let longPress = UILongPressGestureRecognizer(target: self, action: "longPressBackSpace:")
            button.addGestureRecognizer(longPress)
            singleTap.requireGestureRecognizerToFail(longPress)
            button.userInteractionEnabled = true
        } else if title == "space" {
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
        } else if title == "123" || title == "rtn" || title == "\u{1f310}" || title == "+#="{
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
            button.layer.opacity = 0.5
            button.backgroundColor = UIColor.lightGrayColor()
        }
        
        return button
    }
    
    func setUpDecryptionView(){
        self.decryptionView = UIView(frame: CGRectMake(0, 0, 320, 50))
        //self.decryptionView.backgroundColor = UIColor(red: 0.388, green: 0.388, blue: 0.388, alpha: 0.2)
        self.decryptionView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.945, alpha: 1.0)
        self.view.addSubview(self.decryptionView)
        self.decryptionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let alphaSelector: Selector = "toggleCryption"
        let upSwipe = UISwipeGestureRecognizer(target: self, action: alphaSelector)
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        upSwipe.numberOfTouchesRequired = 1
        self.decryptionView.addGestureRecognizer(upSwipe)
        
        self.decryptionDirectionsView = UIView(frame: CGRectMake(0, 0, 320, 50))
        self.decryptionTextView = UIView(frame: CGRectMake(0, 0, 320, 50))
        self.decryptionView.addSubview(self.decryptionTextView)
        self.decryptionView.addSubview(self.decryptionDirectionsView)
        self.decryptionTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.decryptionDirectionsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        self.addDecryptionSubViewConstraints()
        self.decryptionViewConstraints()
        
        self.createDecryptButton()
        self.decryptionDirectionsView.addSubview(self.decryptButton)
        self.decryptButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addDecryptButtonConstraints()
        
        self.decryptedTextLabel.text = ""
        self.decryptionTextView.addSubview(self.decryptedTextLabel)
        self.decryptedTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addDecryptedTextLabelConstraints()
        self.decryptedTextLabel.numberOfLines = 0
        self.decryptedTextLabel.textAlignment = .Center
        self.view.layoutIfNeeded()
    }
    
    /* Constraint Crazy */
    
    func decryptionViewConstraints(){
        var encryptionRowHeight = NSLayoutConstraint(item: self.encryptionRow, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.rowHeight!)
        self.view.addConstraint(encryptionRowHeight)
        
        self.decryptionTopConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Top, relatedBy: .Equal, toItem: self.encryptionRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.decryptionBottomConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: -200)
        self.decryptionLeftConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0)
        self.decryptionRightConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0)
        self.view.addConstraints([self.decryptionTopConstraint,self.decryptionBottomConstraint,self.decryptionLeftConstraint,self.decryptionRightConstraint])
    }
    
    func addDecryptionSubViewConstraints(){
        var directionTopConstraint = NSLayoutConstraint(item: self.decryptionDirectionsView, attribute: .Top, relatedBy: .Equal, toItem: self.decryptionView, attribute: .Top, multiplier: 1.0, constant: 0)
        var directionRightConstraint = NSLayoutConstraint(item: self.decryptionDirectionsView, attribute: .Right, relatedBy: .Equal, toItem: self.decryptionView, attribute: .Right, multiplier: 1.0, constant: 0)
        var directionLeftConstraint = NSLayoutConstraint(item: self.decryptionDirectionsView, attribute: .Left, relatedBy: .Equal, toItem: self.decryptionView, attribute: .Left, multiplier: 1.0, constant: 0)
        var directionBottomConstraint = NSLayoutConstraint(item: self.decryptionDirectionsView, attribute: .Bottom, relatedBy: .Equal, toItem: self.decryptionTextView, attribute: .Top, multiplier: 1.0, constant: 0)
        var directionHeightConstraint = NSLayoutConstraint(item: self.decryptionDirectionsView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.rowHeight!)
        directionHeightConstraint.priority = 800
        self.decryptionView.addConstraints([directionTopConstraint,directionLeftConstraint,directionRightConstraint,directionBottomConstraint,directionHeightConstraint])
        
        var textTopConstraint = NSLayoutConstraint(item: self.decryptionTextView, attribute: .Top, relatedBy: .Equal, toItem: self.decryptionDirectionsView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        var textBottomConstraint = NSLayoutConstraint(item: self.decryptionTextView, attribute: .Bottom, relatedBy: .Equal, toItem: self.decryptionView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        var textLeftConstraint = NSLayoutConstraint(item: self.decryptionTextView, attribute: .Left, relatedBy: .Equal, toItem: self.decryptionView, attribute: .Left, multiplier: 1.0, constant: 0)
        var textRightConstraint = NSLayoutConstraint(item: self.decryptionTextView, attribute: .Right, relatedBy: .Equal, toItem: self.decryptionView, attribute: .Right, multiplier: 1.0, constant: 0)
        self.decryptionView.addConstraints([textTopConstraint,textLeftConstraint,textRightConstraint,textBottomConstraint])
    }
    
    func addDecryptedTextLabelConstraints(){
        var topConstraint = NSLayoutConstraint(item: self.decryptedTextLabel, attribute: .Top, relatedBy: .Equal, toItem: self.decryptionTextView, attribute: .Top, multiplier: 1.0, constant: 0)
        var rightConstraint = NSLayoutConstraint(item: self.decryptedTextLabel, attribute: .Right, relatedBy: .Equal, toItem: self.decryptionTextView, attribute: .Right, multiplier: 1.0, constant: -20)
        var leftConstraint = NSLayoutConstraint(item: self.decryptedTextLabel, attribute: .Left, relatedBy: .Equal, toItem: self.decryptionTextView, attribute: .Left, multiplier: 1.0, constant: 20)
        self.decryptionTextView.addConstraints([topConstraint,rightConstraint,leftConstraint])
    }
    
    func addDecryptButtonConstraints(){
        var bottomConstraint = NSLayoutConstraint(item: self.decryptButton, attribute: .Bottom, relatedBy: .Equal, toItem: self.decryptionDirectionsView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        var topConstraint = NSLayoutConstraint(item: self.decryptButton, attribute: .Top, relatedBy: .Equal, toItem: self.decryptionDirectionsView, attribute: .Top, multiplier: 1.0, constant: 0)
        var leftConstraint = NSLayoutConstraint(item: self.decryptButton, attribute: .Left, relatedBy: .Equal, toItem: self.decryptionDirectionsView, attribute: .Left, multiplier: 1.0, constant: 0)
        var rightConstraint = NSLayoutConstraint(item: self.decryptButton, attribute: .Right, relatedBy: .Equal, toItem: self.decryptionDirectionsView, attribute: .Right, multiplier: 1.0, constant: 0)
        self.decryptionDirectionsView.addConstraints([bottomConstraint,topConstraint,leftConstraint,rightConstraint])
    }
    
    //Constraints for the raw text encryption row
    func constraintsForRawTextLabel(){
        var buttonTop = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Top, relatedBy: .Equal, toItem: self.rawTextLabel, attribute: .Top, multiplier: 1.0, constant: 0)
        var buttonBottom = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Bottom, relatedBy: .Equal, toItem: self.rawTextLabel, attribute: .Bottom, multiplier: 1.0, constant: 0)
        var buttonLeft = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Left, relatedBy: .Equal, toItem: self.rawTextLabel, attribute: .Left, multiplier: 1.0, constant: 0)
        var widthConstraint = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50)
        self.rawTextLabel.addConstraints([buttonTop,buttonBottom,buttonLeft,widthConstraint])
        
        var topConstraint = NSLayoutConstraint(item: self.rawTextLabel, attribute: .Top, relatedBy: .Equal, toItem: self.encryptionRow, attribute: .Top, multiplier: 1.0, constant: 0)
        var bottomConstraint = NSLayoutConstraint(item: self.rawTextLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.encryptionRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
        var leftConstraint = NSLayoutConstraint(item: self.rawTextLabel, attribute: .Left, relatedBy: .Equal, toItem: self.encryptionRow, attribute: .Left, multiplier: 1.0, constant: 0)
        var rightConstraint = NSLayoutConstraint(item: self.rawTextLabel, attribute: .Right, relatedBy: .Equal, toItem: self.encryptionRow, attribute: .Right, multiplier: 1.0, constant: 0)
        self.encryptionRow.addConstraints([topConstraint,bottomConstraint,leftConstraint,rightConstraint])
    }
    
    func addBottomRowConstraints(buttons: [UIButton], mainView: UIView){
        
        for (index, button) in enumerate(buttons) {
            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 5)
            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -5)
            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -5)
                var widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 90)
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
            } else {
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -5)
            }
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 5)
                var widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40)
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
            } else {
                let prevtButton = buttons[index-1]
                if index == 1 || index == 2{
                    var widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30)
                    widthConstraint.priority = 800
                    mainView.addConstraint(widthConstraint)
                }
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 5)
            }
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        
        for (index, button) in enumerate(buttons) {
            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 5)
            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: -5)
            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -5)
            } else {
                let nextButton = buttons[index+1]
                if button.titleForState(.Normal) == "\u{21E7}" {
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -20)
                } else {
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -5)
                }
            }
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 5)
            } else {
                let prevtButton = buttons[index-1]
                if button.titleForState(.Normal) == "\u{232B}" {
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: -40)
                    var widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 48)
                    widthConstraint.priority = 800
                    mainView.addConstraint(widthConstraint)
                } else {
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 5)
                    let firstButton = buttons[0]
                    var widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                    widthConstraint.priority = 800
                    mainView.addConstraint(widthConstraint)
                }
            }
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        
        for (index, rowView) in enumerate(rowViews) {
            if index == 2 {
                var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: -15)
                var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 15)
                inputView.addConstraints([leftConstraint, rightSideConstraint])
            } else {
                var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: 0)
                var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 0)
                inputView.addConstraints([leftConstraint, rightSideConstraint])
            }
            
            var topConstraint: NSLayoutConstraint
            
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1.0, constant: 0)
                
            }else{
                
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .Top, relatedBy: .Equal, toItem: prevRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
                let firstRow = rowViews[0]
                var heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .Height, relatedBy: .Equal, toItem: rowView, attribute: .Height, multiplier: 1.0, constant: 0)
                
                heightConstraint.priority = 800
                inputView.addConstraint(heightConstraint)
            }
            
            switch (index) {
            case 0:
                self.row0Con = topConstraint
                inputView.addConstraint(self.row0Con)
            case 1:
                self.row1Con = topConstraint
                inputView.addConstraint(self.row1Con)
            case 2:
                self.row2Con = topConstraint
                inputView.addConstraint(self.row2Con)
            case 3:
                self.row3Con = topConstraint
                inputView.addConstraint(self.row3Con)
            case 4:
                self.row4Con = topConstraint
                inputView.addConstraint(self.row4Con)
            default:
                println("Okay now")
                inputView.addConstraint(topConstraint)
            }
            
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1.0, constant: 0)
                self.row4ConBottom = bottomConstraint
                inputView.addConstraint(self.row4ConBottom)
                
            }else{
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 0)
            }
            
            inputView.addConstraint(bottomConstraint)
        }
    }
    
}
