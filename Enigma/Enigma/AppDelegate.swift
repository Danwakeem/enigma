//
//  AppDelegate.swift
//  Enigma
//
//  Created by Bradley Slayter on 1/22/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		#if DEBUG
		EncrytionFramework.test()
		#endif
		
		// DELETE THESE TWO LINES FOR DEFAULT BEHAVIOR
		// These lines force the tutorial to be shown every time the app is launched. For testing purposes only.
		//var userDefaults = NSUserDefaults.standardUserDefaults()
		//userDefaults.setBool(false, forKey: "hasSeenTutorial")
		
		// Split view controller
		let splitViewController = self.window!.rootViewController as! SplitViewController
		splitViewController.managedObjectContext = self.managedObjectContext
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        println("Hello")
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		self.saveContext()
	}
    
    func parseProfile(profile: String) {
        let profileArray = split(profile) {$0 == ","}
        
        if profileArray.count > 2 {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let entity = NSEntityDescription.entityForName("Profiles", inManagedObjectContext: managedContext)
            let newProfile = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            
            newProfile.setValue(profileArray[0], forKey: "name")
            
            let numEncryptions = profileArray[1].toInt()
            let newSet = NSMutableOrderedSet()
            println("numEncryptions: \(numEncryptions)")
            
            for var i = 2; i < profileArray.count; i++ {
                let encryptionEntity = NSEntityDescription.entityForName("Encryptions", inManagedObjectContext: managedContext)
                let encryption = NSManagedObject(entity: encryptionEntity!, insertIntoManagedObjectContext:managedContext)
                
                let encrTypeIndex = i++
                let encrKeyIndex = i
                encryption.setValue(profileArray[encrTypeIndex], forKey: "encryptionType")
                encryption.setValue(profileArray[encrKeyIndex], forKey: "key1")
                if profileArray[encrTypeIndex] == "Affine" {
                    let encrKeyIndex2 = ++i
                    encryption.setValue(profileArray[encrKeyIndex2], forKey: "key2")
                }
                newSet.addObject(encryption)
            }
            
            newProfile.setValue(newSet, forKey: "encryption")
            
            
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("ProfileUpdated", object: newProfile)
            NSNotificationCenter.defaultCenter().postNotificationName("ProfileFromURL", object: newProfile)
        } else {
            UIAlertView(title: "Error", message: "Could not import profile.", delegate: nil, cancelButtonTitle: "Ok").show()
        }
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        var string:String! = url.host?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        
        if let pro = string{
            let profile = EncrytionFramework.decrypt(pro, using: Caesar, withKey: "13", andKey: 0)
            println("Scanned: \(profile)")
            parseProfile(profile)
        }
        return true
    }

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named "com.Danwakeem.Brace_Editor" in the application's documents Application Support directory.
		//let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		//return urls[urls.count-1] as NSURL

		let urls = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.enigma")
		return urls!
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = NSBundle.mainBundle().URLForResource("Enigma", withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
		// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Enigma.sqlite")
		var error: NSError? = nil
		var failureReason = "There was an error creating or loading the application's saved data."
		if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
			coordinator = nil
			// Report any error we got.
			let dict = NSMutableDictionary()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			dict[NSUnderlyingErrorKey] = error
			error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(error), \(error!.userInfo)")
			abort()
		}

		return coordinator
	}()

	lazy var managedObjectContext: NSManagedObjectContext? = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		if coordinator == nil {
			return nil
		}
		var managedObjectContext = NSManagedObjectContext()
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()

	// MARK: - Core Data Saving support

	func saveContext () {
		if let moc = self.managedObjectContext {
			var error: NSError? = nil
			if moc.hasChanges && !moc.save(&error) {
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				NSLog("Unresolved error \(error), \(error!.userInfo)")
				abort()
			}
		}
	}
}

