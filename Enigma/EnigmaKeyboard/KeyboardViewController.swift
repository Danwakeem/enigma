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

    @IBOutlet var nextKeyboardButton: UIButton!

    override func updateViewConstraints() {
        super.updateViewConstraints()
    
        // Add custom view sizing constraints here
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        //The values for al the keys
        let buttonTitles1 = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
        let buttonTitles2 = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
        let buttonTitles3 = ["uc", "z", "x", "c", "v", "b", "n", "m", "bp"]
        let buttonTitles4 = ["chg", "space", "return"]
        
        //Row of buttons as a view. Example "qwertyuiop"
        var row1 = rowOfButtons(buttonTitles1)
        var row2 = rowOfButtons(buttonTitles2)
        var row3 = rowOfButtons(buttonTitles3)
        var row4 = rowOfButtons(buttonTitles4)
        
        //add the views of button arrays to the screen
        self.view.addSubview(row1)
        self.view.addSubview(row2)
        self.view.addSubview(row3)
        self.view.addSubview(row4)
        
        //Disable all of the autolayout stuff that gets automatically set by adding a subview that way
        //we can add our own autolayout attributes
        row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        row4.setTranslatesAutoresizingMaskIntoConstraints(false)

        //Adding the constraints to the rows of keys. I took these constraints from the tutorial I followed
        addConstraintsToInputView(self.view, rowViews: [row1, row2, row3, row4])
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
        addIndividualButtonConstraints(buttons, mainView: keyboardRowView)
        
        return keyboardRowView
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
    
    //Creating a button with the title from the button* arrays
    func createButtonWithTitle(title: String) -> UIButton {
        
        let button = UIButton.buttonWithType(.System) as UIButton
        button.frame = CGRectMake(0, 0, 20, 20)
        button.clipsToBounds = true
        button.setTitle(title, forState: .Normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFontOfSize(15)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        
        button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    func buttonTapped(sender: AnyObject?) {
        
        let button = sender as UIButton
        //This is where I set where the button title goes when the user hits a button.
        var proxy = textDocumentProxy as UITextDocumentProxy
        
        if let title = button.titleForState(.Normal) {
            switch title {
            case "bp" :
                proxy.deleteBackward()
            case "return" :
                proxy.insertText("\n")
            case "space" :
                proxy.insertText(" ")
            case "chg" :
                self.advanceToNextInputMode()
            default :
                proxy.insertText(title)
            }
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
                rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: nextButton, attribute: .Left, multiplier: 1.0, constant: 0)
            }
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 0)
            } else {
                let prevtButton = buttons[index-1]
                if button.titleForState(.Normal) == "z"  || button.titleForState(.Normal) == "bp" {
                    println("adding space")
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: prevtButton, attribute: .Right, multiplier: 1.0, constant: 15)
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
            if index == 1 {
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
