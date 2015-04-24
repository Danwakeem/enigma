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
	func nameSelected()
}

class ProfileDetailHeaderView: UICollectionReusableView, UITextFieldDelegate {
	@IBOutlet weak var profileNameField: UITextField!
	
	var delegate: ProfileDetailHeaderViewDelegate! = nil
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		delegate.nameSelected()
		
		return true
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		delegate.profileNameChanged(textField.text)
		
		textField.resignFirstResponder()
		
		return true
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		delegate.profileNameChanged(textField.text)
	}
}
