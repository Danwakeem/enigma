//
//  ShareViewController.swift
//  Enigma
//
//  Created by Jake Singer on 4/11/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
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
	
	@IBAction func shareQRCode(sender: AnyObject) {
		var items: [AnyObject] = [AnyObject]()
		items.append(qrCodeView.image!)
		
		let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
		self.presentViewController(vc, animated: true, completion: nil)
	}
	
}
