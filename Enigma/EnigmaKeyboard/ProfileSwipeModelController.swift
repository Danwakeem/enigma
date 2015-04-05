//
//  ProfileSwipeModelController.swift
//  Enigma
//
//  Created by Dan jarvis on 4/3/15.
//  Copyright (c) 2015 Flipped Bit. All rights reserved.
//

import UIKit

class ProfileSwipeModelController: NSObject, UIPageViewControllerDataSource {
    
    var profileData = NSArray()
    var currentData: NSManagedObject!
    var fetchedResultsController = ProfileFetchModel().fetchedResultsController
    let swipedNotification = "com.SlayterDev.swipedProfile"
    var textColor: UIColor!
    
    override init() {
        super.init()
        // Create the data model.
        self.profileData = fetchedResultsController.fetchedObjects as [NSManagedObject]
        
    }

    func viewControllerAtIndex(index: Int, textColor: UIColor) -> ProfileSwipeViewController? {
        // Return the data view controller for the given index.
        self.textColor = textColor
        if (profileData.count == 0) || (index >= profileData.count) {
            return nil
        }
        
        var profile: NSManagedObject = profileData[index] as NSManagedObject
        self.currentData = profile
        var name = profile.valueForKey("name")?.description
        
        let profileSwipeViewController = ProfileSwipeViewController(obj: profile, color: self.textColor)
        
        return profileSwipeViewController
    }
    
    func indexOfViewController(viewController: ProfileSwipeViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        if let dataObject: AnyObject = viewController.profileObject {
            var dict = ["Profile": dataObject as NSManagedObject]
            NSNotificationCenter.defaultCenter().postNotificationName(self.swipedNotification, object: self, userInfo: dict)
            return self.profileData.indexOfObject(dataObject)
        } else {
            return NSNotFound
        }
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as ProfileSwipeViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index, textColor: self.textColor)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as ProfileSwipeViewController)
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == self.profileData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, textColor: self.textColor)
    }
}