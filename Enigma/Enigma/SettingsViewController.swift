//
//  SettingsViewController.swift
//  Enigma
//
//  Created by Bradley Slayter on 2/13/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, PasscodeViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
	
	lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "com.Danwakeem.Brace_Editor" in the application's documents Application Support directory.
		//let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		//return urls[urls.count-1] as NSURL
		
		let urls = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.enigma")
		return urls!
		}()
    
    var colorSelection = ["Default", "Black", "White", "Green", "Blue", "Pink"]
    var pickerView: UIPickerView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        self.pickerView = UIPickerView(frame: CGRectMake(0, 0, 100, 60))
        self.pickerView.showsSelectionIndicator = true
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.pickerView.setTranslatesAutoresizingMaskIntoConstraints(false)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
        let defaults = NSUserDefaults(suiteName: "group.com.enigma")
        if let color = defaults?.valueForKey("KeyboardColor") as? String {
            var selectedColor: Int!
            for (index,value) in enumerate(self.colorSelection) {
                if value == color {
                    selectedColor = index
                }
            }
            self.pickerView.selectRow(selectedColor, inComponent: 0, animated: true)
        }
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5;
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return (UIScreen.mainScreen().bounds.size.height-44.0)/5
	}
	
	@IBAction func doneTapped(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Touch ID/Passcode"
			cell.detailTextLabel?.text = "Enable touch ID to get access to this app"
		case 1:
			cell.textLabel?.text = "Typing Sounds"
			cell.detailTextLabel?.text = "Play a sound as you type on the keyboard"
		case 2:
			cell.textLabel?.text = "Quick Period"
			cell.detailTextLabel?.text = "Double tap the space bar to insert a period"
		case 3:
			cell.textLabel?.text = "Swipe to Change Profiles"
			cell.detailTextLabel?.text = "Right swipe across the clear text bar to\nchange encryption profiles"
		case 4:
			cell.textLabel?.text = "Color Scheme"
			cell.detailTextLabel?.text = "Change the color of the keyboard"
            var pickerContainter = UIView(frame: CGRectMake(0, 0, 100, 100))
            pickerContainter.backgroundColor = UIColor.clearColor()
            pickerContainter.setTranslatesAutoresizingMaskIntoConstraints(false)
            cell.addSubview(pickerContainter)
            pickerContainter.addSubview(self.pickerView)
            self.constraintsForPickerView(cell, pickerView: pickerContainter)
		default:
			cell.textLabel?.text = ""
		}
		
		if indexPath.row < 4 {
			cell.accessoryView = createSwitch(indexPath.row)
		}
		
		cell.selectionStyle = .None
		
		return cell
	}
	
	func checkSwitchStatus(index: Int) -> Bool {
		let defaults = NSUserDefaults(suiteName: "group.com.enigma")
		
		switch index {
		case 0:
			if (defaults!.boolForKey("PasscodeSet")) {
				return true
			}
		case 1:
			if (defaults!.boolForKey("TypingSounds")) {
				return true
			}
		case 2:
			if (defaults!.boolForKey("QuickPeriod")) {
				return true
			}
		case 3:
			if (defaults!.boolForKey("ProfileSwipe")) {
				return true
			}
		default:
			return false
		}
		
		return false
	}
	
	func setPasscode() {
		let vc = PasscodeView()
		vc.setup = true
		vc.delegate = self
		self.presentViewController(vc, animated: true, completion: nil)
	}
	
	func authenticationCompleted(success: Bool) {
		println("We did it!")
	}
	
	func switchTapped(sender: AnyObject) {
		let selectedSwitch = sender as UISwitch
		let defaults = NSUserDefaults(suiteName: "group.com.enigma")
		
		switch selectedSwitch.tag {
		case 0:
			if !selectedSwitch.on {
				defaults?.setBool(false, forKey: "PasscodeSet")
				defaults?.setValue("", forKey: "passcode")
			} else {
				setPasscode()
			}
		case 1:
			defaults?.setBool(selectedSwitch.on, forKey: "TypingSounds")
		case 2:
			defaults?.setBool(selectedSwitch.on, forKey: "QuickPeriod")
		case 3:
			defaults?.setBool(selectedSwitch.on, forKey: "ProfileSwipe")
		default:
			break
		}
		
	}
	
	func createSwitch(index: Int) -> UISwitch {
		let newSwitch = UISwitch();
		newSwitch.addTarget(self, action: "switchTapped:", forControlEvents: .ValueChanged)
		newSwitch.tag = index
		
		newSwitch.setOn(checkSwitchStatus(index), animated: false)
		
		return newSwitch
	}
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let defaults = NSUserDefaults(suiteName: "group.com.enigma")
        defaults?.setValue(self.colorSelection[row], forKey: "KeyboardColor")
        println(self.colorSelection[row])
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.colorSelection.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if row >= 0 && row < self.colorSelection.count {
            return self.colorSelection[row]
        } else {
            return "ERROR"
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100.0
    }
    
    func constraintsForPickerView(cell: UIView, pickerView: UIView) {
        let top = NSLayoutConstraint(item: pickerView, attribute: .Top, relatedBy: .Equal, toItem: cell, attribute: .Top, multiplier: 1.0, constant: 30)
        //let centerX = NSLayoutConstraint(item: pickerView, attribute: .CenterX, relatedBy: .Equal, toItem: cell, attribute: .CenterX, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: pickerView, attribute: .Right, relatedBy: .Equal, toItem: cell, attribute: .Right, multiplier: 1.0, constant: -20)
        let height = NSLayoutConstraint(item: pickerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 60)
        let width = NSLayoutConstraint(item: pickerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        cell.addConstraints([top,right,height,width])
        
        let pvTop = NSLayoutConstraint(item: self.pickerView, attribute: .Top, relatedBy: .Equal, toItem: pickerView, attribute: .Top, multiplier: 1.0, constant: 0)
        let pvLeft = NSLayoutConstraint(item: self.pickerView, attribute: .Left, relatedBy: .Equal, toItem: pickerView, attribute: .Left, multiplier: 1.0, constant: 0)
        let pvRight = NSLayoutConstraint(item: self.pickerView, attribute: .Right, relatedBy: .Equal, toItem: pickerView, attribute: .Right, multiplier: 1.0, constant: 0)
        let pvBottom = NSLayoutConstraint(item: self.pickerView, attribute: .Bottom, relatedBy: .Equal, toItem: pickerView, attribute: .Bottom, multiplier: 1.0, constant: 0)
        pickerView.addConstraints([pvTop,pvLeft,pvRight,pvBottom])
    }
	
}
