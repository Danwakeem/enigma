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
    var encryptDecryptToggle: Bool = false
    
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
    
    var encryptionRow: UIView!
    var row1: UIView!
    var row2: UIView!
    var row3: UIView!
    var row4: UIView!
    
    @IBOutlet var nextKeyboardButton: UIButton!

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = UIColor.whiteColor()
        self.view = UIVisualEffectView()
        self.view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.createKeyboard()
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
    
    func swipe(sender: UISwipeGestureRecognizer){
        //This is where I can change the keyboard layout
    }
    
    func toggleAlphaKeyboard(sender: UISwipeGestureRecognizer) {
        self.removeViews()
        self.createKeyboard()
    }
    
    func toggleNumberKeyboard(sender: UISwipeGestureRecognizer) {
        self.removeViews()
        self.changeToNumberBoard()
    }
    
    func lockCase(sender: AnyObject?) {
        self.caseLock = !self.caseLock
    }
    
    func longPressBackSpace(sender: AnyObject) {
        self.proxy.deleteBackward()
    }
    
    func buttonTapped(sender: AnyObject?) {
        let button = sender as UIButton
        
        if let title = button.titleForState(.Normal) {
            switch title {
            case "BP" :
                self.proxy.deleteBackward()
                //Getting rid of the last typed word with input field
                if !self.lastTypedWord.isEmpty {
                    self.lastTypedWord = self.lastTypedWord.substringToIndex(self.lastTypedWord.endIndex.predecessor())
                }
            case "RTN" :
                self.proxy.insertText("\n")
            case "SPACE" :
                //This is where we would access self.lastTypedWord to encrypt their text.
                //Just use self.proxy.deleteBackward() to delete each char the user typed until it is gone then replace with the encrypted string.
                if self.lastTypedWord == " " {
                    self.proxy.deleteBackward()
                    self.proxy.insertText(". ")
                    self.lastTypedWord = " "
                } else {
                    self.proxy.insertText(" ")
                    self.lastTypedWord = " "
                }
            case "\u{1f310}" :
				let context = proxy.documentContextBeforeInput
				if context.hasSuffix(" ") {
					proxy.deleteBackward()
					proxy.insertText(". ")
				} else {
					proxy.insertText(" ")
				}
            case "CHG" :
                self.advanceToNextInputMode()
            case "\u{21ea}" :
                self.upperCase = !self.upperCase
            case "123" :
                self.removeViews()
                self.changeToNumberBoard()
            case "ABC" :
                self.removeViews()
                self.createKeyboard()
            default :
                if self.upperCase || self.caseLock || self.firstLetter {
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
                    self.proxy.insertText(title.lowercaseString)
                    self.lastTypedWord += title.lowercaseString
                }
            }
        }
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
    
    func createKeyboard(){
        //Row of buttons as a view. Example "qwertyuiop"
        self.encryptionRow = UIView(frame: CGRectMake(0, 0, 320, 50))
        self.encryptionRow.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.945, alpha: 0.2)
        self.row1 = rowOfButtons(self.buttonTitles1)
        self.row2 = rowOfButtons(self.buttonTitles2)
        self.row3 = rowOfButtons(self.buttonTitles3)
        self.row4 = rowOfButtons(self.buttonTitles4)
        
        //add the views of button arrays to the screen
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
        
        //Adding the constraints to the rows of keys. I took these constraints from the tutorial I followed
        addConstraintsToInputView(self.view, rowViews: [self.encryptionRow, self.row1, self.row2, self.row3, self.row4])
        
    }
    
    func changeToNumberBoard() {
        self.encryptionRow = UIView(frame: CGRectMake(0, 0, 320, 50))
        self.encryptionRow.backgroundColor = UIColor(red: 0.949, green: 0.945, blue: 0.945, alpha: 0.2)
        self.row1 = rowOfButtons(self.numberButtonTitles1)
        self.row2 = rowOfButtons(self.numberButtonTitles2)
        self.row3 = rowOfButtons(self.numberButtonTitles3)
        self.row4 = rowOfButtons(self.numberButtonTitles4)
        
        //add the views of button arrays to the screen
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
        
        //Adding the constraints to the rows of keys. I took these constraints from the tutorial I followed
        addConstraintsToInputView(self.view, rowViews: [self.encryptionRow, self.row1, self.row2, self.row3, self.row4])
        
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
        button.backgroundColor = UIColor(red: 232/255, green: 234/255, blue: 237/255, alpha: 0.2)
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
