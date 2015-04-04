//
//  ProfileSwipeViewController.swift
//  Enigma
//
//  Created by Dan jarvis on 4/3/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class ProfileSwipeViewController: UIViewController {
    var profileNameLabel: UILabel!
    var profileObject: NSManagedObject?
    
    init(obj: NSManagedObject) {
        super.init()
        self.profileNameLabel = UILabel(frame: CGRectMake(0, 0, 320, 50))
        self.profileNameLabel.textAlignment = .Center
        self.profileObject = obj
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.clearColor()
        self.view.addSubview(self.profileNameLabel)
        self.profileNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.labelConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.profileNameLabel.text = "Hey there"
        if let obj: String = profileObject?.valueForKey("name")?.description {
            self.profileNameLabel.text = obj
        } else {
            self.profileNameLabel.text = ""
        }
    }
    
    func labelConstraints(){
        let top = NSLayoutConstraint(item: self.profileNameLabel, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.profileNameLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: self.profileNameLabel, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: self.profileNameLabel, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0)
        self.view.addConstraints([top,bottom,right,left])
    }
}
