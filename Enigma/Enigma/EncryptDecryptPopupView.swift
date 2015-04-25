//
//  EncryptDecryptPopupView.swift
//  Enigma
//
//  Created by Dan jarvis on 4/25/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

enum PopupType {
    case Encrypt
    case Decrypt
}

protocol EncryptDecryptPopupViewDelegate {
    func closePop(AnyObject)
    func decryptText(String)
    func encryptString(String)
}

class EncryptDecryptPopupView: UIViewController, UITextViewDelegate {
    var delegate: EncryptDecryptPopupViewDelegate?
    var popupType: PopupType!
    
    var lastTypedWord: String = ""
    
    var blurView: UIVisualEffectView!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView.delegate = self
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "decryptText:")
        doubleTap.numberOfTapsRequired = 2
        textView.addGestureRecognizer(doubleTap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButton(sender: AnyObject) {
        self.delegate?.closePop(self)
    }
    
    func decryptText(sender: AnyObject) {
        self.delegate?.decryptText(textView.text)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let  char = text.cStringUsingEncoding(NSUTF8StringEncoding)!
        let isBackSpace = strcmp(char, "\\b")
        if (isBackSpace == -92) {
            if lastTypedWord != "" {
                lastTypedWord = lastTypedWord.substringWithRange(Range<String.Index>(start: lastTypedWord.startIndex, end: lastTypedWord.endIndex.predecessor()))
            }
        }
        if text == " " || text == "\n" {
            encryptString()
            lastTypedWord = ""
        } else {
            if lastTypedWord == "" {
                lastTypedWord = text
            } else {
                lastTypedWord += text
            }
        }
        return true
    }
    
    func addEncryptedString(string: String) {
        for ch in lastTypedWord {
            textView.text = textView.text.substringWithRange(Range<String.Index>(start: textView.text.startIndex, end: textView.text.endIndex.predecessor()))
        }
        if textView.text != "" {
            textView.text! += string
        } else {
            textView.text = string
        }
    }
    
    func showDecryptedString(string: String) {
        textView.text = string
    }
    
    func encryptString(){
        self.delegate?.encryptString(lastTypedWord)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = ""
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
