//
//  ProfileDetailCell.swift
//  Enigma
//
//  Created by Jake Singer on 2/17/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

protocol ProfileDetailCellDelegate {
	func cypherChanged(key: String, value: String)
}

class ProfileDetailCell: UICollectionViewCell, UITextFieldDelegate {
	@IBOutlet weak var cypherButton: UIButton!
	@IBOutlet weak var keyField: UITextField!
	
	var delegate: ProfileDetailCellDelegate! = nil
	var method = 0
	
	var encryptionMethods = [
		"SimpleSub",
		"Caesar",
		"Affine",
		"Clear",
		"Vigenere"
	]
	
	func textFieldDidEndEditing(textField: UITextField) {
		delegate.cypherChanged("key1", value: keyField.text)
	}
	
	@IBAction func changeEncryptionMethod(sender: AnyObject) {
		method++
		method %= encryptionMethods.count
		delegate.cypherChanged("encryptionMethod", value: encryptionMethods[method])
	}
}
