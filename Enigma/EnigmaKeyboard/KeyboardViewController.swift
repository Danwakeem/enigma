//
//  KeyboardViewController.swift
//  EnigmaKeyboard
//
//  Created by Dan jarvis on 1/23/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

/* I followed a tutorial to get all of this stuff ready to go.
* We dont have to use this set up if you guys don't want to I am just trying to learn.
* Here is the URL if you would like to take a look:
* http://www.appdesignvault.com/ios-8-custom-keyboard-extension/
* The reason I was looking at this one was becasue it showed you how to set it up without a nib.
*/

import UIKit

class KeyboardViewController: UIInputViewController {
    
    var upperCase: Bool = false
    var caseLock: Bool = false
    var firstLetter: Bool = true
    var lastTypedWord: String = ""
    var proxy: UITextDocumentProxy!
    
    //21ea == uppercase
    //1f310 == Globe
    let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
    let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
    let buttonTitles3 = ["\u{21ea}", "Z", "X", "C", "V", "B", "N", "M", "BP"]
    let buttonTitles4 = ["123", "\u{1f310}", "SPACE", "RTN"]
    
    let numberButtonTitles1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    let numberButtonTitles2 = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
    let numberButtonTitles3 = ["+#=", ".", ",", "?", "!", "'", "BP"]
    let numberButtonTitles4 = ["ABC", "\u{1f310}", "SPACE", "RTN"]
    
    let alternateKeyboardButtonTitles1 = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]
    let alternateKeyboardButtonTitles2 = ["_", "\\", "|", "~", "<", ">", "¢", "£", "¥", "•"]
    let alternateKeyboardButtonTitles3 = ["123", ".", ",", "?", "!", "'", "BP"]
    
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
    
    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        //self.view = UIVisualEffectView()
        //self.view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        self.proxy = textDocumentProxy as UITextDocumentProxy
        
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
            case "BP" :
                self.pressedBackSpace(title)
            case "RTN" :
                self.lastTypedWord = ""
                self.rawTextLabel.text = ""
                self.proxy.insertText("\n")
            case "SPACE" :
                self.pressedSpace(title)
            case "\u{1f310}" :
                self.advanceToNextInputMode()
            case "\u{21ea}" :
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
    
    func pressedSpace(title: String){
        self.rawTextLabel.text = ""
        //This is where we would access self.lastTypedWord to encrypt their text.
        //Just use self.proxy.deleteBackward() to delete each char the user typed until it is gone then replace with the encrypted string.
        if self.lastTypedWord == " " {
            self.proxy.deleteBackward()
            self.proxy.insertText(". ")
            self.lastTypedWord = " "
        } else {
            //Encryption test :)
            var encryptedString = EncrytionFramework.encrypt(self.lastTypedWord, using: Caesar, withKey: "13", andKey: 0)
            for ch in self.lastTypedWord{
                self.proxy.deleteBackward()
            }
            self.proxy.insertText(encryptedString + " ")
            self.lastTypedWord = " "
        }
    }
    
    func insertText(title: String){
        if self.upperCase || self.caseLock || self.firstLetter {
            self.setRawTextlabelText(title)
            self.proxy.insertText(title)
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
            self.proxy.insertText(title.lowercaseString)
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
            self.animateDecryptionView()
            self.removeGestures()
        } else {
            self.decryptionView.removeFromSuperview()
            self.decryptionDirectionsView.removeFromSuperview()
            self.decryptionTextView.removeFromSuperview()
            self.toggleEncryptDecrypt.setTitle("E", forState: .Normal)
            self.decryptedTextLabel.removeFromSuperview()
            self.decryptButton.removeFromSuperview()
            self.view.backgroundColor = UIColor.whiteColor()
            createKeyboard([self.buttonTitles1,self.buttonTitles2,self.buttonTitles3,self.buttonTitles4])
        }
    }
    
    func animateDecryptionView(){
        var newBottomConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut , animations: {
            self.view.removeConstraint(self.decryptionBottomConstraint)
            self.view.addConstraint(newBottomConstraint)
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        self.decryptionBottomConstraint = newBottomConstraint
    }
    
    func decryptPasteboard(){
        let pasteBoard = UIPasteboard.generalPasteboard()
        if let text = pasteBoard.string {
            self.decryptedTextLabel.text = self.decryptText(text)
        }
    }
    
    func decryptText(text: String) -> String{
         return EncrytionFramework.decrypt(text, using: Caesar, withKey: "13", andKey: 0)
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
    
    /* Keyboard setup */
    
    func createKeyboard(buttonTitles: [AnyObject]){
        //Row of buttons as a view. Example "qwertyuiop"
        self.encryptionRow = UIView(frame: CGRectMake(0, 0, 320, 50))
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
        self.toggleEncryptDecrypt.frame = CGRectMake(0, 0, 50, 50)
        self.toggleEncryptDecrypt.clipsToBounds = true
        self.toggleEncryptDecrypt.sizeToFit()
        self.toggleEncryptDecrypt.titleLabel?.font = UIFont.systemFontOfSize(15)
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
        if(buttons[1].titleForState(.Normal) == "\u{1f310}"){
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
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor.whiteColor()
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        
        let singleTap = UITapGestureRecognizer(target: self, action: "buttonTapped:")
        singleTap.numberOfTapsRequired = 1
        button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        
        if title == "\u{21ea}" {
            let doubleTap = UITapGestureRecognizer(target: self, action: "lockCase:")
            doubleTap.numberOfTapsRequired = 2
            button.addGestureRecognizer(doubleTap)
            singleTap.requireGestureRecognizerToFail(doubleTap)
        } else if title == "BP" {
            let longPress = UILongPressGestureRecognizer(target: self, action: "longPressBackSpace:")
            button.addGestureRecognizer(longPress)
            singleTap.requireGestureRecognizerToFail(longPress)
            button.userInteractionEnabled = true
            
        }
        
        return button
    }
    
    func setUpDecryptionView(){
        self.decryptionView = UIView(frame: CGRectMake(0, 0, 320, 50))
        self.decryptionView.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.945, alpha: 1.0)
        self.view.addSubview(self.decryptionView)
        self.decryptionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
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
            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 1)
            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: 0)
            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: 0)
                var widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 80)
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
            } else {
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: 0)
            }
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 0)
                var widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40)
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
            } else {
                let prevtButton = buttons[index-1]
                if index == 1 {
                    var widthConstraint = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50)
                    widthConstraint.priority = 800
                    mainView.addConstraint(widthConstraint)
                }
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 0)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        
        for (index, button) in enumerate(buttons) {
            var topConstraint = NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: mainView, attribute: .Top, multiplier: 1.0, constant: 1)
            var bottomConstraint = NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: mainView, attribute: .Bottom, multiplier: 1.0, constant: 0)
            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: 0)
            } else {
                let nextButton = buttons[index+1]
                if button.titleForState(.Normal) == "\u{21ea}" || button.titleForState(.Normal) == "M" {
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: -12)
                } else {
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: 0)
                }
            }
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 0)
            } else {
                let prevtButton = buttons[index-1]
                if button.titleForState(.Normal) == "BP" {
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 12)
                } else {
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 0)
                }
                let firstButton = buttons[0]
                var widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Width, multiplier: 1.0, constant: 0)
                widthConstraint.priority = 800
                mainView.addConstraint(widthConstraint)
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
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1.0, constant: 0)
                
            }else{
                
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .Bottom, relatedBy: .Equal, toItem: nextRow, attribute: .Top, multiplier: 1.0, constant: 0)
            }
            
            inputView.addConstraint(bottomConstraint)
        }
    }
    
}
