//
//  AboutViewController.swift
//  Enigma
//
//  Created by Bradley Slayter on 4/3/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func bradTapped(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.com/apps/slayterdevelopment")!)
	}
	
	@IBAction func danTapped(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://www.wakeemmedia.com")!)
	}
	
	@IBAction func jakeTapped(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://www.jakesinger.com")!)
	}

	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
