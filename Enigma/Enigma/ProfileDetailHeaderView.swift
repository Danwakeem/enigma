//
//  ProfileDetailHeaderView.swift
//  Enigma
//
//  Created by Jake Singer on 2/10/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

protocol ProfileDetailHeaderViewDelegate {
	func profileNameChanged(name: String)
}

class ProfileDetailHeaderView: UICollectionReusableView, UITextFieldDelegate {
	@IBOutlet weak var profileNameField: UITextField!
	
	var delegate: ProfileDetailHeaderViewDelegate! = nil
	
	func textFieldDidEndEditing(textField: UITextField) {
		delegate.profileNameChanged(textField.text)
	}
}
