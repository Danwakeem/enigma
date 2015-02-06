//
//  ViewController.swift
//  Enigma
//
//  Created by Bradley Slayter on 1/22/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		EncrytionFramework.test()
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.presentViewController(PasscodeView(), animated: true, completion: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

