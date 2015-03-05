//
//  ProfileDetailCell.swift
//  Enigma
//
//  Created by Jake Singer on 2/17/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

protocol ProfileDetailCellDelegate {
	func cypherChanged(cypher: String, key1: String, key2: String)
}

class ProfileDetailCell: UICollectionViewCell, UITextFieldDelegate {
	@IBOutlet weak var cypherButton: UIButton!
	@IBOutlet weak var keyField: UITextField!
	
	var delegate: ProfileDetailCellDelegate! = nil
	
	func textFieldDidEndEditing(textField: UITextField) {
		delegate.cypherChanged("Caesar", key1: keyField.text, key2: "")
	}
}
