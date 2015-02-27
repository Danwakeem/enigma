//
//  PopupViewController.swift
//  Enigma
//
//  Created by Dan jarvis on 2/23/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

protocol NewProfilePopupViewControllerDelegate {
    func closePop(sender:AnyObject)
    func cancelPop(sender:AnyObject)
}

class NewProfilePopupViewController: UIViewController, UITextFieldDelegate {
    var delegate:NewProfilePopupViewControllerDelegate?
    
    @IBOutlet weak var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        self.delegate?.closePop(self)
    }
    
    @IBAction func cancelPop(sender: AnyObject) {
        self.delegate?.cancelPop(self)
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField!) -> Bool
    {
        textField.resignFirstResponder()
        return true;
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

