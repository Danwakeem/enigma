//
//  ProfileDetailViewController.swift
//  Enigma
//
//  Created by Jake Singer on 2/5/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

class ProfileDetailViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var appDelegate = AppDelegate()
    
    var encryptions: [AnyObject] = []
	
	@IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var encryptionType: UILabel!
    
    @IBOutlet weak var encryptionKey: UILabel!
    
    var detailItem: NSManagedObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.nameLabel {
                label.text = detail.valueForKey("name")!.description
            }
        }
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureView()
        self.encryptionType.text! = ""
        self.encryptionKey.text! = ""
        self.managedObjectContext = self.appDelegate.managedObjectContext!
        self.getEncryption()
		setNeedsStatusBarAppearanceUpdate()
	}
	
	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .LightContent
	}
    
    func getEncryption(){
        if let encryptions: NSSet = self.detailItem?.mutableSetValueForKeyPath("encryption"){
            for (index,e) in enumerate(encryptions) {
                if index == 0 {
                    self.encryptionType.text! += e.valueForKeyPath("encryptionType") as String! + ", "
                    self.encryptionKey.text! += e.valueForKeyPath("key1") as String! + ", "
                } else {
                    self.encryptionType.text! += e.valueForKeyPath("encryptionType") as String!
                    self.encryptionKey.text! += e.valueForKeyPath("key1") as String!
                }
                if let key2: String = e.valueForKeyPath("key2") as? String {
                    println(key2)
                }
            }
        } else {
            println("\n\nSorry Jabroni")
        }
    }
}






















