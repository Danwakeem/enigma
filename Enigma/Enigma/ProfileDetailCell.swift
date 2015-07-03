//
//  ProfileDetailCell.swift
//  Enigma
//
//  Created by Jake Singer on 2/17/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

protocol ProfileDetailCellDelegate {
	func cypherChanged(cell: ProfileDetailCell, key: String, value: String)
	func focusOnView(cell: ProfileDetailCell)
	func deleteEncryptionType(cell: ProfileDetailCell)
    func sendTextToDelegate(string: String)
}

class ProfileDetailCell: UICollectionViewCell, UITextFieldDelegate {
	var cypherButton: UIButton = UIButton()
    
    @IBOutlet weak var cypherSelection: UISegmentedControl!
	@IBOutlet weak var keyField: UITextField!
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var helpLabel: UILabel!
    @IBOutlet weak var key2Label: UILabel!
    @IBOutlet weak var key2Field: UITextField!

	
	var delegate: ProfileDetailCellDelegate! = nil
	var method = 0
	
	var encryptionMethods = [
		"SimpleSub",
		"Caesar",
		"Vigenere",
        "Affine"
	]
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		delegate.focusOnView(self)
		
		return true
	}
    	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		delegate.cypherChanged(self, key: "key1", value: keyField.text)
		textField.resignFirstResponder()
		
		return true
	}
    
    func setCypherSelectionGesture(){
        var tap = UITapGestureRecognizer(target: self, action: "changeEncryptionMethod:")
        tap.numberOfTapsRequired = 1
        cypherSelection.addGestureRecognizer(tap)
    }
    
	func textFieldDidEndEditing(textField: UITextField) {
        println("Hello")
		//delegate.cypherChanged(self, key: "key1", value: keyField.text)
	}
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        sendTextToDelegate(string)
        return true
    }
    
    func sendTextToDelegate(string: String) {
        delegate.sendTextToDelegate(string)
    }
    
    @IBAction func key1Change(sender: AnyObject) {
        delegate.cypherChanged(self, key: "key1", value: keyField.text)
    }
    
    @IBAction func key2Change(sender: AnyObject) {
        delegate.cypherChanged(self, key: "key2", value: key2Field.text)
    }
	
    @IBAction func changeEncryptMethod(sender: AnyObject) {
        var title = cypherSelection.titleForSegmentAtIndex(cypherSelection.selectedSegmentIndex)!
        
        changeMethod(title)
        
        self.helpLabel.text = EncrytionFramework.helpStringForEncryptionType(encryptionMethods[method])
        delegate.cypherChanged(self, key: "encryptionType", value: encryptionMethods[method])
    }
    
    func changeMethod(title: String){
        switch title {
        case "Simple Sub":
            method = 0
        case "Caesar":
            method = 1
        case "Vigenere":
            method = 2
        default:
            method = 3
        }
    }
	
	@IBAction func deleteMe(sender: AnyObject) {
		println("Delete encryption method")
		delegate.deleteEncryptionType(self)
	}
}
