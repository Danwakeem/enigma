//
//  KeyboardView.swift
//  Enigma
//
//  Created by Dan jarvis on 3/29/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

protocol KeyboardViewDelegate {
    func decryptPasteboard()
    func buttonTapped(sender: AnyObject)
    func longPressBackSpace(sender: AnyObject)
    func lockCase(sender: AnyObject)
	func backSpaceTapped(sender: AnyObject)
	func backSpaceReleased(sender: AnyObject)
}

class KeyboardView: UIView, UIPageViewControllerDelegate {
    
    var delegate: KeyboardViewDelegate?
    
    //Buttons
    let buttonTitles1 = ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"]
    let buttonTitles2 = ["A", "S", "D", "F", "G", "H", "J", "K", "L"]
    let buttonTitles3 = ["\u{21E7}", "Z", "X", "C", "V", "B", "N", "M", "\u{232B}"]
    let buttonTitles4 = ["123", "👱", "\u{1f310}", "space", "return"]
    
    let numberButtonTitles1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    let numberButtonTitles2 = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
    let numberButtonTitles3 = ["+#=", ".", ",", "?", "!", "'", "\u{232B}"]
    let numberButtonTitles4 = ["ABC", "👱", "\u{1f310}", "space", "return"]
    
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
    
    var isAlternateKeyboard = false
    var canSwitchToAlphaKeyboard = false
    
    var profileSwipeRow: UIView!
    var profilePages: UIPageViewController!
    var initilizedPageIndex: Int!
    var showProfilePages: NSTimer!
    var profilePagesHide: Bool = false
    
    var shiftKey: UIButton!

    var decryptionTopConstraint: NSLayoutConstraint!
    var decryptionBottomConstraint: NSLayoutConstraint!
    var decryptionLeftConstraint: NSLayoutConstraint!
    var decryptionRightConstraint: NSLayoutConstraint!
    
    var row0Con: NSLayoutConstraint!
    var row1Con: NSLayoutConstraint!
    var row2Con: NSLayoutConstraint!
    var row3Con: NSLayoutConstraint!
    var row4Con: NSLayoutConstraint!
    var row4ConBottom: NSLayoutConstraint!

    let rawTextLabel: UILabel = UILabel(frame: CGRectMake(0, 0, 350, 50))
    let toggleEncryptDecrypt: UIButton = UIButton()
    let decryptButton: UIButton = UIButton()
    let decryptedTextLabel: UILabel = UILabel(frame: CGRectMake(0, 0, 350, 50))
    
    var viewBackgroundColor = UIColor(white: 0.999, alpha: 0.01)
    var encryptionRowColor = UIColor(red: 0.949, green: 0.945, blue: 0.945, alpha: 1.0)
    var decryptEncryptButtonTextColor = UIColor.darkGrayColor()
    var decryptEncryptButtonColor = UIColor(red: 0.91, green: 0.902, blue: 0.902, alpha: 1.0)
    var keysBackgroundColor = UIColor.whiteColor()
    var keysTextColor = UIColor.darkTextColor()
    var specialKeysButtonColor = UIColor.lightGrayColor()
    var otherSpecialKeysTextColor = UIColor.lightGrayColor()
    var decryptionViewColor = UIColor(red: 0.949, green: 0.945, blue: 0.945, alpha: 1.0)
    var profilePageTextColor = UIColor.lightGrayColor()
    var decryptedTextColor = UIColor.darkTextColor()
    
    var keysPressedColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.0)
    var shiftKeyPressedColor = UIColor(red: 0.941, green: 0.941, blue: 0.941, alpha: 1.0)
    
    var popupKey: PopupKey!
    
    var nearestButton: UIButton!
    
    var foundSpecialButton: Bool = false
    
    var a: UIButton!
    
    var l: UIButton!
    
    var keyboardColor: String!
    
    var device: String = ""
    var popupEnabled: Bool = true
    
    
    //MARK: - initialization
    
    required init(){
        super.init(frame: CGRectMake(0, 0, 320, 275))
        self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
    }
    
    init(index: Int, color: String){
        super.init(frame: CGRectZero)
        self.initilizedPageIndex = index
        self.phoneModel()
        self.keyboardColor = color
        if color == "Default" {
            self.backgroundColor = self.viewBackgroundColor
            self.popupKey = PopupKey(backgroundColor: self.keysBackgroundColor, textColor: self.keysTextColor, device: self.device)
            self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        } else {
            self.changeColorsToSettings(color)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //iPhone 6+ -- W: 414.0 H: 736.0
    //iPhone 6  -- W: 375.0 H: 667.0
    //iPhone 5  -- W: 320.0 H: 568.0
    //iPhone 4  -- W: 320.0 H: 480.0
    func phoneModel(){
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        switch width {
        case 414.0:
            self.device = "iPhone6+"
        case 736.0:
            self.device = "iPhone6+"
        case 667.0:
            self.device = "iPhone6"
        case 375.0:
            self.device = "iPhone6"
        case 568.0:
            self.device = "iPhone5"
        case 480.0:
            self.device = "iPhone4"
        case 320.0:
            if height == 568.0 {
                self.device = "iPhone5"
            } else {
                self.device = "iPhone4"
            }
        default:
            self.device = "iPad"
        }
        println("Device type: \(self.device)")
    }
    
    // MARK - Change keyboard color
    
    func changeColorsToSettings(color: String) {
        switch color {
        case "White":
            self.popupKey = PopupKey(backgroundColor: self.keysBackgroundColor, textColor: self.keysTextColor, device: self.device)
            self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        case "Black":
            self.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0)
            self.encryptionRowColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0)
            self.decryptEncryptButtonTextColor = UIColor.whiteColor()
            self.decryptEncryptButtonColor = UIColor(red: 0.114, green: 0.114, blue: 0.114, alpha: 1.0)
            self.keysBackgroundColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0)
            self.keysTextColor = UIColor.whiteColor()
            self.specialKeysButtonColor = UIColor(red: 0.169, green: 0.169, blue: 0.169, alpha: 1.0)
            self.decryptionViewColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0)
            self.profilePageTextColor = UIColor.whiteColor()
            self.decryptedTextColor = UIColor.whiteColor()
            self.rawTextLabel.textColor = UIColor.whiteColor()
            self.keysPressedColor = UIColor(red: 0.047, green: 0.047, blue: 0.047, alpha: 1.0)
            self.shiftKeyPressedColor = UIColor(red: 0.047, green: 0.047, blue: 0.047, alpha: 1.0)
            self.popupKey = PopupKey(backgroundColor: self.keysBackgroundColor, textColor: self.keysTextColor, device: self.device)
            self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        case "Blue":
            self.backgroundColor = UIColor(red: 0.161, green: 0.62, blue: 0.91, alpha: 1.0)
            self.encryptionRowColor = UIColor(red: 0.106, green: 0.396, blue: 0.831, alpha: 1.0)
            self.decryptEncryptButtonTextColor = UIColor.whiteColor()
            self.decryptEncryptButtonColor = UIColor(red: 0.043, green: 0.506, blue: 0.8, alpha: 1.0)
            self.keysBackgroundColor = UIColor(red: 0.106, green: 0.396, blue: 0.831, alpha: 1.0)
            self.keysTextColor = UIColor.whiteColor()
            self.specialKeysButtonColor = UIColor(red: 0.043, green: 0.506, blue: 0.8, alpha: 1.0)
            self.decryptionViewColor = UIColor(red: 0.106, green: 0.396, blue: 0.831, alpha: 1.0)
            self.profilePageTextColor = UIColor.whiteColor()
            self.decryptedTextColor = UIColor.whiteColor()
            self.rawTextLabel.textColor = UIColor.whiteColor()
            self.keysPressedColor = UIColor(red: 0.075, green: 0.325, blue: 0.628, alpha: 1.0)
            self.shiftKeyPressedColor = UIColor(red: 0.075, green: 0.325, blue: 0.628, alpha: 1.0)
            self.popupKey = PopupKey(backgroundColor: self.keysBackgroundColor, textColor: self.keysTextColor, device: self.device)
            self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        case "Pink":
            self.backgroundColor = UIColor(red: 0.953, green: 0.604, blue: 0.792, alpha: 1.0)
            self.encryptionRowColor = UIColor(red: 0.918, green: 0.388, blue: 0.675, alpha: 1.0)
            self.decryptEncryptButtonTextColor = UIColor.whiteColor()
            self.decryptEncryptButtonColor = UIColor(red: 0.933, green: 0.478, blue: 0.722, alpha: 1.0)
            self.keysBackgroundColor = UIColor(red: 0.918, green: 0.388, blue: 0.675, alpha: 1.0)
            self.keysTextColor = UIColor.whiteColor()
            self.specialKeysButtonColor = UIColor(red: 0.933, green: 0.478, blue: 0.722, alpha: 1.0)
            self.decryptionViewColor = UIColor(red: 0.918, green: 0.388, blue: 0.675, alpha: 1.0)
            self.profilePageTextColor = UIColor.whiteColor()
            self.decryptedTextColor = UIColor.whiteColor()
            self.rawTextLabel.textColor = UIColor.whiteColor()
            self.keysPressedColor = UIColor(red: 0.827, green: 0.318, blue: 0.592, alpha: 1.0)
            self.shiftKeyPressedColor = UIColor(red: 0.827, green: 0.318, blue: 0.592, alpha: 1.0)
            self.popupKey = PopupKey(backgroundColor: self.keysBackgroundColor, textColor: self.keysTextColor, device: self.device)
            self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        case "Green":
            self.backgroundColor = UIColor(red: 0.016, green: 0.792, blue: 0.353, alpha: 1.0)
            self.encryptionRowColor = UIColor(red: 0.067, green: 0.584, blue: 0.29, alpha: 1.0)
            self.decryptEncryptButtonTextColor = UIColor.whiteColor()
            self.decryptEncryptButtonColor = UIColor(red: 0.027, green: 0.663, blue: 0.302, alpha: 1.0)
            self.keysBackgroundColor = UIColor(red: 0.067, green: 0.584, blue: 0.29, alpha: 1.0)
            self.keysTextColor = UIColor.whiteColor()
            self.specialKeysButtonColor = UIColor(red: 0.027, green: 0.663, blue: 0.302, alpha: 1.0)
            self.decryptionViewColor = UIColor(red: 0.067, green: 0.584, blue: 0.29, alpha: 1.0)
            self.profilePageTextColor = UIColor.whiteColor()
            self.decryptedTextColor = UIColor.whiteColor()
            self.rawTextLabel.textColor = UIColor.whiteColor()
            self.keysPressedColor = UIColor(red: 0.047, green: 0.482, blue: 0.235, alpha: 1.0)
            self.shiftKeyPressedColor = UIColor(red: 0.047, green: 0.482, blue: 0.235, alpha: 1.0)
            self.popupKey = PopupKey(backgroundColor: self.keysBackgroundColor, textColor: self.keysTextColor, device: self.device)
            self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        default:
            self.backgroundColor = self.viewBackgroundColor
            self.popupKey = PopupKey(backgroundColor: self.keysBackgroundColor, textColor: self.keysTextColor, device: self.device)
            self.createKeyboard([buttonTitles1,buttonTitles2,buttonTitles3,buttonTitles4])
        }
    }
    
    func loadAsDarkKeyboard(){
        self.keyboardColor = "Black"
        self.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0)
        self.encryptionRowColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0)
        self.decryptEncryptButtonTextColor = UIColor.whiteColor()
        self.decryptEncryptButtonColor = UIColor(red: 0.114, green: 0.114, blue: 0.114, alpha: 1.0)
        self.keysBackgroundColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0)
        self.keysTextColor = UIColor.whiteColor()
        self.specialKeysButtonColor = UIColor(red: 0.169, green: 0.169, blue: 0.169, alpha: 1.0)
        self.decryptionViewColor = UIColor(red: 0.125, green: 0.125, blue: 0.125, alpha: 1.0)
        self.profilePageTextColor = UIColor.whiteColor()
        self.decryptedTextColor = UIColor.whiteColor()
        self.rawTextLabel.textColor = UIColor.whiteColor()
        self.keysPressedColor = UIColor(red: 0.047, green: 0.047, blue: 0.047, alpha: 1.0)
        self.shiftKeyPressedColor = UIColor(red: 0.047, green: 0.047, blue: 0.047, alpha: 1.0)
        self.popupKey = PopupKey(backgroundColor: self.keysBackgroundColor, textColor: self.keysTextColor, device: self.device)
    }
    
    //MARK: - Delegate methods
    
    func removeGestures(){
        for gesture in self.gestureRecognizers as! [UIGestureRecognizer] {
            self.removeGestureRecognizer(gesture)
        }
    }
    
    func decryptPasteboard(){
        self.delegate?.decryptPasteboard()
    }
    
    func buttonTapped(sender: AnyObject){
        if self.initilizedPageIndex != -1 {
            if self.profilePages.view.superview != nil {
                self.showProfilePages.invalidate()
                self.profilePages.view.alpha = 0.0
                self.profilePages.view.removeFromSuperview()
            }
        }
        self.toggleColor(sender)

        self.delegate?.buttonTapped(sender)
    }
	
	func backSpaceTapped(sender: AnyObject) {
		var button = sender as! UIButton
        button.backgroundColor = self.specialKeysButtonColor
        self.delegate?.backSpaceTapped(sender)
	}
	
	func backSpaceReleased(sender: AnyObject) {
        var button = sender as! UIButton
        button.backgroundColor = self.specialKeysButtonColor
        self.delegate?.backSpaceReleased(sender)
	}
    
    func longPressBackSpace(sender: AnyObject){
        self.delegate?.longPressBackSpace(sender)
    }
    
    func lockCase(sender: AnyObject){
        self.delegate?.lockCase(sender)
    }
    
    func removeViews(){
        for v in self.subviews {
            v.removeFromSuperview()
        }
    }
    
    func buttonPressed(sender: AnyObject) {
        var button = sender as! UIButton
        button.backgroundColor = self.keysPressedColor
        if self.popupEnabled  && self.device != "iPad" {
            self.keyPopup(button)
        }
    }
    
    func keyPopup(button: UIButton){
        let title: String = button.titleForState(.Normal)!
        if self.isPopupKey(title) {
            var frame = button.frame
            self.popupKey!.label.text = title
            self.popupKeyXOffset(frame)
            self.popupKey!.frame.origin.y = frame.origin.y - self.popupKey!.height + 45
            if self.iPhone6PlusTopRow(button) {
                self.popupKey!.duck = true
                if self.upperLeftButton(title) {
                    self.popupKey!.leftUpper = true
                    self.popupKey!.frame.origin.x += 11
                } else if self.upperRightButton(title) {
                    self.popupKey!.rightUpper = true
                    self.popupKey!.frame.origin.x -= 14
                }
            } else if self.upperLeftButton(title) {
                self.popupKey!.leftUpper = true
                self.popupKey!.frame.origin.x += 10
            } else if self.upperRightButton(title) {
                self.popupKey!.rightUpper = true
                self.popupKey!.frame.origin.x -= 12
            } else if self.specialKeyPopup(title) {
                self.popupKey!.specialWideKey = true
                self.popupKey!.frame.origin.x -= 2
                self.popupKeyYOffset(frame)
                self.popupKey.changeFrame(self.popupKey.frame.origin.x, y: self.popupKey.frame.origin.y)
            }
            self.popupKey!.redoConstraintsForLabel()
            self.popupKey!.setNeedsDisplay()
            button.superview?.addSubview(self.popupKey!)
        }
    }
    
    func iPhone6PlusTopRow(button: UIButton) -> Bool {
        if self.device == "iPhone6+" && button.superview == self.row1 || button.superview == self.numberButtonTitles1 || button.superview == self.alternateKeyboardButtonTitles1 {
            return true
        }
        return false
    }
    
    func upperLeftButton(title: String) -> Bool {
        if title == "Q" || title == "1" || title == "["  || title == "-" || title == "_" {
            return true
        }
        return false
    }
    
    func upperRightButton(title: String) -> Bool {
        if title == "P" || title == "0" || title == "=" || title == "\"" || title == "•" {
            return true
        }
        return false
    }
    
    func specialKeyPopup(title: String) -> Bool {
        if title == "." || title == "," || title == "?" || title == "!" || title ==  "'" {
            return true
        }
        return false
    }
    
    func popupKeyXOffset(frame: CGRect){
        //iPhone 6+ -- self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 52
        //iPhone 6  -- self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 45
        //iPhone 5  -- self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 38
        //iPhone 4s -- self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 37
        switch self.device {
        case "iPhone6+":
            self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 52
        case "iPhone6":
            self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 45
        case "iPhone5":
            self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 38
        case "iPhone4":
            self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 37
        default:
            self.popupKey!.frame.origin.x = frame.origin.x - self.popupKey!.width + 52
        }
    }
    
    func popupKeyYOffset(frame: CGRect) {
        switch self.device {
        case "iPhone6+":
            self.popupKey!.frame.origin.y -= 35 as CGFloat
        case "iPhone6":
            self.popupKey!.frame.origin.y -= 30 as CGFloat
        case "iPhone5":
            self.popupKey!.frame.origin.y -= 25 as CGFloat
        case "iPhone4":
            self.popupKey!.frame.origin.y -= 24 as CGFloat
        default:
            self.popupKey!.frame.origin.y -= 30 as CGFloat
        }
    }
    
    func isPopupKey(title: String) -> Bool {
        if title != "space" && title != "return" && title != "ABC" && title != "123" && title != "\u{232B}" && title != "👱"
            && title != "+#=" && title != "\u{21E7}" && title != "\u{1f310}" {
            return true
        }
        return false
    }
    
    func toggleColor(sender: AnyObject){
        if let superView = self.popupKey.superview {
            self.popupKey.duck = false
            self.popupKey.rightUpper = false
            self.popupKey.leftUpper = false
            self.popupKey.specialWideKey = false
            self.popupKey.frame = CGRectMake(0, 0, self.popupKey.width, self.popupKey.height)
            self.popupKey.removeFromSuperview()
        }
        let button = sender as! UIButton
        var title: String = button.titleForState(.Normal)!
        switch (title) {
        case "123":
            button.backgroundColor = self.specialKeysButtonColor
        case "return":
            button.backgroundColor = self.specialKeysButtonColor
        case "+#=":
            button.backgroundColor = self.specialKeysButtonColor
        case "\u{21E7}":
            button.backgroundColor = self.specialKeysButtonColor
            println("Shift")
        default:
            button.backgroundColor = self.keysBackgroundColor
        }
    }
    
    func nearestButton(tap: TouchDownGestureRecognizer) {
        //self.buttonTapped(self.nearestButton)
        let v = tap.view
        let location = tap.locationInView(v)
        var selectedButton: UIButton!
        for (index, button) in enumerate(v?.subviews as! [UIButton]) {
            if index == 0 {
                selectedButton = button
            }
            var x = button.superview?.convertRect(button.frame, fromView: v)
            if x?.origin.x < location.x {
                selectedButton = button
            }
        }
        self.buttonTapped(selectedButton)
    }
    
    func aOrL(tap: TouchDownGestureRecognizer) {
        if self.popupKey.superview == nil && self.popupEnabled {
            let v = tap.view
            let location = tap.locationInView(v)
            let width = self.frame.width
            if width / 2 < location.x {
                self.nearestButton = self.l
                self.keyPopup(self.l)
                self.nearestButton = self.l
            } else {
                self.nearestButton = self.a
                self.keyPopup(self.a)
            }
        } else {
            self.popupKey.duck = false
            self.popupKey.rightUpper = false
            self.popupKey.leftUpper = false
            self.popupKey.specialWideKey = false
            self.popupKey.frame = CGRectMake(0, 0, self.popupKey.width, self.popupKey.height)
            self.popupKey.removeFromSuperview()
            self.buttonTapped(self.nearestButton)
        }
    }
    
    func nearestButtonPopupKey(tap: TouchDownGestureRecognizer) {
        var selectedButton: UIButton!
        if self.popupKey.superview == nil && self.popupEnabled {
            let v = tap.view
            if v != self.row4 {
                let location = tap.locationInView(v)
                for (index, button) in enumerate(v?.subviews as! [UIButton]) {
                    if index == 0 {
                        selectedButton = button
                    }
                    var x = button.superview?.convertRect(button.frame, fromView: v)
                    if x?.origin.x < location.x {
                        selectedButton = button
                    }
                }
                let title = selectedButton.titleForState(.Normal)
                if isPopupKey(title!) {
                    self.keyPopup(selectedButton)
                } else {
                    if !self.foundSpecialButton {
                        if title == "\u{232B}" {
                            self.backSpaceTapped(selectedButton)
                        } else if title == "\u{21E7}" {
                            self.buttonTapped(selectedButton)
                            if self.shiftKey.backgroundColor == self.shiftKeyPressedColor {
                                self.shiftKey.backgroundColor = self.specialKeysButtonColor
                            } else {
                                self.shiftKey.backgroundColor = self.shiftKeyPressedColor
                            }
                        } else {
                            self.buttonTapped(selectedButton)
                        }
                    } else {
                        if title == "\u{232B}" {
                            self.backSpaceReleased(selectedButton)
                        }
                    }
                    self.foundSpecialButton = !self.foundSpecialButton
                }
            } else {
                if !self.foundSpecialButton {
                    self.nearestButton(tap)
                }
                self.foundSpecialButton = !self.foundSpecialButton
            }
        } else {
            self.popupKey.duck = false
            self.popupKey.rightUpper = false
            self.popupKey.leftUpper = false
            self.popupKey.specialWideKey = false
            self.popupKey.frame = CGRectMake(0, 0, self.popupKey.width, self.popupKey.height)
            self.popupKey.removeFromSuperview()
            self.buttonTapped(self.nearestButton)
            self.nearestButton = nil
        }
        
        self.nearestButton = selectedButton
    }
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(pageViewController: UIPageViewController, spineLocationForInterfaceOrientation orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
        let currentViewController = self.profilePages!.viewControllers[0] as! UIViewController
        let viewControllers = [currentViewController]
        self.profilePages!.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: {done in })
        
        self.profilePages!.doubleSided = false
        return .Min
    }
    
    //MARK: - Keyboard view animations
    
    func toggleCryption(){
        if self.toggleEncryptDecrypt.titleForState(.Normal) == "E" {
            self.toggleEncryptDecrypt.setTitle("D", forState: .Normal)
            let frame = self.encryptionRow.frame
            self.rowHeight = frame.height
            self.setUpDecryptionView()
            self.animateDecryptionViewIn()
            //self.removeGestures()
        } else {
            self.animateDecryptionViewOut()
            self.toggleEncryptDecrypt.setTitle("E", forState: .Normal)
        }
    }
    
    func animateDecryptionViewIn(){
        var newBottomConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut , animations: {
            self.removeConstraint(self.decryptionBottomConstraint)
            self.addConstraint(newBottomConstraint)
            self.layoutIfNeeded()
            
            
            }, completion: nil)
        self.decryptionBottomConstraint = newBottomConstraint
    }
    
    func animateDecryptionViewOut(){
        var newBottomConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -200)
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseIn , animations: {
            self.removeConstraint(self.decryptionBottomConstraint)
            self.addConstraint(newBottomConstraint)
            self.layoutIfNeeded()
            }, completion: {(complete: Bool) -> Void in
                self.removeConstraint(self.row0Con)
                self.decryptionView.removeFromSuperview()
                self.decryptionDirectionsView.removeFromSuperview()
                self.decryptionTextView.removeFromSuperview()
                self.decryptedTextLabel.removeFromSuperview()
                self.decryptButton.removeFromSuperview()
        })
        
        self.decryptionBottomConstraint = newBottomConstraint
    }
    
    //MARK: - Keyboard view creation
    
    func createKeyboard(buttonTitles: [AnyObject]){
        
        self.encryptionRow = UIView(frame: CGRectMake(0, 0, 320, 50))
        self.profileSwipeRow = UIView(frame: CGRectMake(0, 0, 320, 50))
        self.encryptionRow.backgroundColor = self.encryptionRowColor
        self.profileSwipeRow.backgroundColor = UIColor.clearColor()
        
        self.row1 = rowOfButtons(buttonTitles[0] as! [String])
        self.row2 = rowOfButtons(buttonTitles[1] as! [String])
        self.row3 = rowOfButtons(buttonTitles[2] as! [String])
        self.row4 = rowOfButtons(buttonTitles[3] as! [String])
        
        if self.keyboardColor == "Default" || self.keyboardColor == "White" {
            self.row1.backgroundColor = self.viewBackgroundColor
            self.row2.backgroundColor = self.viewBackgroundColor
            self.row3.backgroundColor = self.viewBackgroundColor
            self.row4.backgroundColor = self.viewBackgroundColor
        }
        
        self.createEncryptDecryptToggleButton()
        
        //add the views of button arrays to the screen
        self.encryptionRow.addSubview(self.rawTextLabel)
        self.rawTextLabel.addSubview(self.toggleEncryptDecrypt)
        self.profileSwipeRow.addSubview(self.toggleEncryptDecrypt)
        self.encryptDecryptToggleConstraints()
        self.addSubview(encryptionRow)
        self.addSubview(self.profileSwipeRow)
        self.addSubview(row1)
        self.addSubview(row2)
        self.addSubview(row3)
        self.addSubview(row4)
        
        let alphaSelector: Selector = "toggleCryption"
        let downSwipe = UISwipeGestureRecognizer(target: self, action: alphaSelector)
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        downSwipe.numberOfTouchesRequired = 1
        self.profileSwipeRow.addGestureRecognizer(downSwipe)
        
        //Disable all of the autolayout stuff that gets automatically set by adding a subview that way
        //we can add our own autolayout attributes
        self.encryptionRow.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.profileSwipeRow.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.row1.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.row2.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.row3.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.row4.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.rawTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Adding the constraints to the rows of keys. I took these constraints from the tutorial I followed
        addConstraintsToInputView(self, rowViews: [self.encryptionRow, self.row1, self.row2, self.row3, self.row4])
        
        self.addConstraintsToProfileSwipeRow()
        
        //Add the constraints rawTextView to the encryptionRow
        constraintsForRawTextLabel()
        //Center the text in the label
        self.rawTextLabel.textAlignment = .Center
        
        if self.initilizedPageIndex != -1 {
            //Swipes to activate profile pages
            let aSelector: Selector = "activatePages"
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: aSelector)
            leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
            leftSwipe.numberOfTouchesRequired = 1
            self.profileSwipeRow.addGestureRecognizer(leftSwipe)
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: aSelector)
            rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
            rightSwipe.numberOfTouchesRequired = 1
            self.profileSwipeRow.addGestureRecognizer(rightSwipe)
            
            self.setupPageView()
            
            self.showProfilePages = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("togglePages"), userInfo: nil, repeats: false)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: "nearestButton:")
        tap.numberOfTapsRequired = 1
        let touchDown = TouchDownGestureRecognizer(target: self, action: "nearestButtonPopupKey:")
        self.row1.addGestureRecognizer(tap)
        self.row1.addGestureRecognizer(touchDown)
        
        let tap2 = UITapGestureRecognizer(target: self, action: "nearestButton:")
        tap2.numberOfTapsRequired = 1
        let touchDown2 = TouchDownGestureRecognizer(target: self, action: "nearestButtonPopupKey:")
        self.row2.addGestureRecognizer(tap2)
        self.row2.addGestureRecognizer(touchDown2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: "nearestButton:")
        tap3.numberOfTapsRequired = 1
        let touchDown3 = TouchDownGestureRecognizer(target: self, action: "nearestButtonPopupKey:")
        self.row3.addGestureRecognizer(tap3)
        self.row3.addGestureRecognizer(touchDown3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: "nearestButton:")
        tap4.numberOfTapsRequired = 1
        let touchDown4 = TouchDownGestureRecognizer(target: self, action: "nearestButtonPopupKey:")
        self.row4.addGestureRecognizer(tap4)
        self.row4.addGestureRecognizer(touchDown4)
    }
    
    func activatePages() {
        if self.showProfilePages != nil {
            self.showProfilePages.invalidate()
        }
        self.showProfilePages = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("togglePages"), userInfo: nil, repeats: false)
        self.togglePages()
    }
    
    func togglePages(){
        if let boo = self.profilePages.view.superview {
            self.profilePages.view.alpha = 1.0
            UIView.animateWithDuration(1.0, animations: {self.profilePages.view.alpha = 0.0}, completion: {(yes: Bool) -> Void in
                self.profilePages.view.removeFromSuperview()
            })
            UIView.animateWithDuration(1.0, animations: {self.profilePages.view.alpha = 0.0})
            //self.profilePages.view.removeFromSuperview()
        } else {
            self.profilePages.view.frame = self.profileSwipeRow.frame
            self.profilePages.view.alpha = 0.0
            self.profileSwipeRow.addSubview(self.profilePages.view)
            UIView.animateWithDuration(0.3, animations: {self.profilePages.view.alpha = 1.0})
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        //Increase timer
        if self.showProfilePages != nil {
            self.showProfilePages.invalidate()
        }
        self.showProfilePages = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("togglePages"), userInfo: nil, repeats: false)
    }
    
    func setupPageView() {
        self.profilePages = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.profilePages!.delegate = self
        
        var startingViewController: ProfileSwipeViewController!
        if self.initilizedPageIndex != nil {
            startingViewController = self.profileSwipeModelController.viewControllerAtIndex(self.initilizedPageIndex, textColor: self.profilePageTextColor)!
        } else {
            startingViewController = self.profileSwipeModelController.viewControllerAtIndex(0, textColor: self.profilePageTextColor)!
        }
        let vcs = [startingViewController]
        self.profilePages.setViewControllers(vcs, direction: .Forward, animated: false, completion: {done in})
		
		
		let defaults = NSUserDefaults(suiteName: "group.com.enigma")
		
		if defaults!.boolForKey("ProfileSwipe") == false {
			self.profilePages.view.userInteractionEnabled = false
		}
		
		self.profilePages.dataSource = self.profileSwipeModelController
        
        self.profilePages.view.frame = self.profileSwipeRow.frame
        self.profileSwipeRow.addSubview(self.profilePages.view)
        
        var click = UITapGestureRecognizer(target: self, action: "toggleCryption")
        click.numberOfTapsRequired = 1
        self.profilePages.view.addGestureRecognizer(click)
        
    }
    
    func movePageView(index: Int) {
        var newPage: ProfileSwipeViewController = self.profileSwipeModelController.viewControllerAtIndex(index, textColor: self.profilePageTextColor)!
        let vcs = [newPage]
        self.profilePages.setViewControllers(vcs, direction: .Forward, animated: true, completion: {done in})
    }
    
    var profileSwipeModelController: ProfileSwipeModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _profileSwipeModelController == nil {
            _profileSwipeModelController = ProfileSwipeModelController()
        }
        return _profileSwipeModelController!
    }
    var _profileSwipeModelController: ProfileSwipeModelController? = nil
    
    func createDecryptButton(){
        self.decryptButton.setTitle("Decrypt pasteboard", forState: .Normal)
        self.decryptButton.frame = CGRectMake(0, 0, 320, 50)
        self.decryptButton.clipsToBounds = true
        self.decryptButton.sizeToFit()
        self.decryptButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.decryptButton.backgroundColor = UIColor.clearColor()
        self.decryptButton.setTitleColor(self.decryptEncryptButtonTextColor, forState: .Normal)
        self.decryptButton.addTarget(self, action: "decryptPasteboard", forControlEvents: .TouchUpInside)
        self.decryptButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
    func createEncryptDecryptToggleButton(){
        //So the button is clickable
        self.encryptionRow.userInteractionEnabled = true
        self.rawTextLabel.userInteractionEnabled = true
        
        //Change to a D when you are in decrypt mode
        self.toggleEncryptDecrypt.setTitle("E", forState: .Normal)
        self.toggleEncryptDecrypt.setTitleColor(self.decryptEncryptButtonTextColor, forState: .Normal)
        self.toggleEncryptDecrypt.frame = CGRectMake(0, 0, 50, 50)
        self.toggleEncryptDecrypt.clipsToBounds = true
        self.toggleEncryptDecrypt.sizeToFit()
        self.toggleEncryptDecrypt.titleLabel?.font = UIFont.systemFontOfSize(15)
        self.toggleEncryptDecrypt.backgroundColor = self.decryptEncryptButtonColor
        self.toggleEncryptDecrypt.setTitleColor(self.decryptEncryptButtonTextColor, forState: .Normal)
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
            var button = createButtonWithTitle(buttonTitle as String)
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
        let button = UIButton.buttonWithType(.Custom) as! UIButton
        button.frame = CGRectMake(0, 0, 20, 20)
        button.clipsToBounds = true
        button.setTitle(title, forState: .Normal)
        button.sizeToFit()
        button.titleEdgeInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.backgroundColor = self.keysBackgroundColor
        button.layer.cornerRadius = 5
        button.setTitleColor(self.keysTextColor, forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(20)

        let pressDown = UITapGestureRecognizer(target: self, action: "buttonPressed:")
        pressDown.numberOfTapsRequired = 1
        button.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchDown)

        let singleTap = UITapGestureRecognizer(target: self, action: "buttonTapped:")
        singleTap.numberOfTapsRequired = 1
        button.addTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
        
        let touchOutside = UITapGestureRecognizer(target: self, action: "toggleColor:")
        touchOutside.numberOfTapsRequired = 1
        button.addTarget(self, action: "toggleColor:", forControlEvents: .TouchUpOutside)
        
        if title == "\u{21E7}" {
            button.backgroundColor = self.specialKeysButtonColor
            button.layer.opacity = 0.5
            button.titleLabel?.font = UIFont(name: "LucidaGrande", size: 20)
            let doubleTap = UITapGestureRecognizer(target: self, action: "lockCase:")
            doubleTap.numberOfTapsRequired = 2
            button.addGestureRecognizer(doubleTap)
            singleTap.requireGestureRecognizerToFail(doubleTap)
            self.shiftKey = button
        } else if title == "\u{232B}" {
            button.backgroundColor = self.specialKeysButtonColor
            button.layer.opacity = 0.5
            button.titleLabel?.font = UIFont(name: "LucidaGrande", size: 20)
            button.setTitleColor(self.keysTextColor, forState: .Normal)
            button.removeTarget(self, action: "buttonTapped:", forControlEvents: .TouchUpInside)
			button.addTarget(self, action: "backSpaceTapped:", forControlEvents: .TouchDown)
			button.addTarget(self, action: "backSpaceReleased:", forControlEvents: UIControlEvents.TouchUpInside|UIControlEvents.TouchDragOutside)
        } else if title == "space" {
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
        } else if title == "\u{1f310}" {
            button.titleLabel?.font = UIFont(name: "Quivira", size: 30.0)
            button.setTitleColor(self.keysTextColor, forState: .Normal)
            button.layer.opacity = 0.5
            button.backgroundColor = self.specialKeysButtonColor
        } else if title == "123" || title == "return" || title == "\u{1f310}" || title == "+#=" || title == "ABC" {
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.setTitleColor(self.keysTextColor, forState: .Normal)
            button.layer.opacity = 0.5
            button.backgroundColor = self.specialKeysButtonColor
        } else {
            button.titleLabel?.font = UIFont.systemFontOfSize(20)
        }
        
        if title == "A" {
            self.a = button
        } else if title == "L" {
            self.l = button
        }
        
        return button
    }
    
    func setUpDecryptionView(){
        self.decryptionView = UIView(frame: CGRectMake(0, 0, 320, 50))
        self.decryptionView.backgroundColor = self.decryptionViewColor
        self.addSubview(self.decryptionView)
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
        self.decryptedTextLabel.textColor = self.decryptedTextColor
        self.decryptionTextView.addSubview(self.decryptedTextLabel)
        self.decryptedTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addDecryptedTextLabelConstraints()
        self.decryptedTextLabel.numberOfLines = 0
        self.decryptedTextLabel.textAlignment = .Center
        self.layoutIfNeeded()
    }
    
    //MARK: Constraints
    
    func encryptDecryptToggleConstraints(){
        println("Hello")
        let widthConstraint = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50)
        let top = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Top, relatedBy: .Equal, toItem: self.profileSwipeRow, attribute: .Top, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Left, relatedBy: .Equal, toItem: self.profileSwipeRow, attribute: .Left, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Bottom, relatedBy: .Equal, toItem: self.profileSwipeRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.profileSwipeRow.addConstraints([widthConstraint,top,left,bottom])
    }
    
    func addConstraintsToProfileSwipeRow(){
        
        let bottomConstraint = NSLayoutConstraint(item: self.profileSwipeRow, attribute: .Bottom, relatedBy: .Equal, toItem: self.row1, attribute: .Top, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: self.profileSwipeRow, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.profileSwipeRow, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.profileSwipeRow, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)
        
        self.addConstraints([bottomConstraint,top,leftConstraint,rightConstraint])
    }
    
    func decryptionViewConstraints(){
        var encryptionRowHeight = NSLayoutConstraint(item: self.encryptionRow, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.rowHeight!)
        self.addConstraint(encryptionRowHeight)
        
        self.decryptionTopConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Top, relatedBy: .Equal, toItem: self.encryptionRow, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.decryptionBottomConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -200)
        self.decryptionLeftConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0)
        self.decryptionRightConstraint = NSLayoutConstraint(item: self.decryptionView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0)
        self.addConstraints([self.decryptionTopConstraint,self.decryptionBottomConstraint,self.decryptionLeftConstraint,self.decryptionRightConstraint])
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
        /*
        var buttonTop = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Top, relatedBy: .Equal, toItem: self.rawTextLabel, attribute: .Top, multiplier: 1.0, constant: 0)
        var buttonBottom = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Bottom, relatedBy: .Equal, toItem: self.rawTextLabel, attribute: .Bottom, multiplier: 1.0, constant: 0)
        var buttonLeft = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Left, relatedBy: .Equal, toItem: self.rawTextLabel, attribute: .Left, multiplier: 1.0, constant: 0)
        var widthConstraint = NSLayoutConstraint(item: self.toggleEncryptDecrypt, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 50)
        self.rawTextLabel.addConstraints([buttonTop,buttonBottom,buttonLeft,widthConstraint])
        */
        
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
                if button.titleForState(.Normal) == "L" {
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -20)
                } else {
                    rightConstraint = NSLayoutConstraint(item: button, attribute: .Right, relatedBy: .Equal, toItem: mainView, attribute: .Right, multiplier: 1.0, constant: -5)
                }
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
                if button.titleForState(.Normal) == "A" {
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 20)
                } else {
                    leftConstraint = NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: mainView, attribute: .Left, multiplier: 1.0, constant: 5)
                }
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
            if index == 2  && rowView.subviews.count != 10 {
                var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: 0)
                var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 0)
                inputView.addConstraints([leftConstraint, rightSideConstraint])
                /*
                var rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .Right, relatedBy: .Equal, toItem: inputView, attribute: .Right, multiplier: 1.0, constant: -15)
                var leftConstraint = NSLayoutConstraint(item: rowView, attribute: .Left, relatedBy: .Equal, toItem: inputView, attribute: .Left, multiplier: 1.0, constant: 15)
                inputView.addConstraints([leftConstraint, rightSideConstraint])
                */
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
