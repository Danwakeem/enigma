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
}

class ProfileDetailCell: UICollectionViewCell, UITextFieldDelegate {
	@IBOutlet weak var cypherButton: UIButton!
	@IBOutlet weak var keyField: UITextField!
	@IBOutlet weak var deleteButton: UIButton!
	
	var delegate: ProfileDetailCellDelegate! = nil
	var method = 0
	
	var encryptionMethods = [
		"SimpleSub",
		"Caesar",
		"Affine",
		"Vigenere"
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
	
	func textFieldDidEndEditing(textField: UITextField) {
		delegate.cypherChanged(self, key: "key1", value: keyField.text)
	}
	
	@IBAction func changeEncryptionMethod(sender: AnyObject) {
		method++
		method %= encryptionMethods.count
		delegate.cypherChanged(self, key: "encryptionType", value: encryptionMethods[method])
	}
	
	@IBAction func deleteMe(sender: AnyObject) {
		println("Delete encryption method")
		delegate.deleteEncryptionType(self)
	}
}
