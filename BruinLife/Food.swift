//
//  Favorite.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/7/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import CloudKit
import CoreData

class DiningDay: NSManagedObject {
	@NSManaged var day: NSDate
	@NSManaged var data: NSData
}

class QuickMenu: NSManagedObject {
	@NSManaged var data: NSData
	
	class func dataFromInfo(moc: NSManagedObjectContext, record: CKRecord) -> QuickMenu {
		let newData = record.objectForKey("Data") as! NSData
		if let quick = CloudManager.sharedInstance.quickMenu {
			if quick.data != newData {
				quick.data = newData
				NSNotificationCenter.defaultCenter().postNotificationName("QuickInfoUpdated", object: nil, userInfo:["quickInfo":quick])
			}
			return quick
		}
		
		var newQuick = NSEntityDescription.insertNewObjectForEntityForName("QuickMenu", inManagedObjectContext: moc) as! QuickMenu
		newQuick.data = newData
		
		NSNotificationCenter.defaultCenter().postNotificationName("QuickInfoUpdated", object: nil, userInfo:["quickInfo":newQuick])
		return newQuick
	}
}

class Food: NSManagedObject {
	/// All the information for the entire food
	@NSManaged var data: NSData
	
	@NSManaged var favorite: Bool
	/// Should user be notified when food is available?
	@NSManaged var notify: Bool
	
	/// Day context for servings figure
	@NSManaged var date: NSDate
	@NSManaged var servings: Int16
	
	var info: FoodInfo {
		get {
			return FoodInfo(dict: NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil) as! Dictionary<String, AnyObject>)
		}
	}
	
	class func foodFromInfo(moc: NSManagedObjectContext, food: FoodInfo) -> Food {
		// if it exists, return it straight away. Otherwise make it
		if let food = CloudManager.sharedInstance.eatenFood(food.recipe) {
			return food
		}
		
		var newItem = NSEntityDescription.insertNewObjectForEntityForName("Food", inManagedObjectContext: moc) as! Food
		newItem.data = NSJSONSerialization.dataWithJSONObject(food.dictFromObject(), options: .allZeros, error: nil)!
		newItem.favorite = false
		newItem.notify = false
		newItem.date = comparisonDate()
		newItem.servings = 0
		return newItem
	}
	
	/// Invalidate servings count if the day has changed.
	func checkDate() {
		let compareDate = comparisonDate()
		if !NSCalendar.currentCalendar().isDate(compareDate, inSameDayAsDate: date) {
			date = compareDate
			servings = 0
		}
	}
}
