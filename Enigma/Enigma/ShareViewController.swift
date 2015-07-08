//
//  ShareViewController.swift
//  Enigma
//
//  Created by Jake Singer on 4/11/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import MessageUI

class ShareViewController: UIViewController, MFMessageComposeViewControllerDelegate {
	@IBOutlet weak var qrCodeView: UIImageView!
	
	var profile: NSManagedObject? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var stringToEncode = EncrytionFramework.stringFromProfile(profile)
		var qrCode = createQRForString(stringToEncode)
		var qrCodeImg = createNonInterpolatedUIImageFromCIImage(qrCode, withScale: 4 * UIScreen.mainScreen().scale)
		qrCodeView.image = qrCodeImg
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func createQRForString(qrString: NSString) -> CIImage {
		var stringData = qrString.dataUsingEncoding(NSUTF8StringEncoding)
		var qrFilter = CIFilter(name: "CIQRCodeGenerator")
		qrFilter.setValue(stringData, forKey: "inputMessage")
		qrFilter.setValue("Q", forKey: "inputCorrectionLevel")
		return qrFilter.outputImage
	}
	
	func createNonInterpolatedUIImageFromCIImage(image: CIImage, withScale scale: CGFloat) -> UIImage {
		var rect = image.extent()
		var cgImage = CIContext(options: nil).createCGImage(image, fromRect: rect)
		UIGraphicsBeginImageContext(CGSizeMake(rect.size.width * scale, rect.size.width * scale))
		var context = UIGraphicsGetCurrentContext()
		CGContextSetInterpolationQuality(context, kCGInterpolationNone)
		CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
		var scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return scaledImage
	}
	
	@IBAction func done(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: { () -> Void in
			
		})
	}
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        var encrypProfile = EncrytionFramework.encrypt(EncrytionFramework.stringFromProfile(profile), using: Caesar, withKey: "13", andKey: 0)
        messageComposeVC.body = "Your friend has shared an encryption method with you! Click here to save:\n\n enigmakeyboard://" + encrypProfile + "\n\nif you do not have enigma keyboard installed click here:\n\n https://goo.gl/SJYlKl"
        return messageComposeVC
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareAsText(sender: AnyObject) {
        if canSendText() {
            let messageView = configuredMessageComposeViewController()
            presentViewController(messageView, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
}
