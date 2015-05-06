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

func comparisonDate(date: NSDate) -> NSDate {
	return currCal.startOfDayForDate(date)
}

func comparisonDate(daysInFuture: Int = 0) -> NSDate {
	return currCal.dateByAddingUnit(.CalendarUnitDay, value: daysInFuture, toDate: comparisonDate(NSDate()), options: nil)!
}

class DiningDay: NSManagedObject {
	@NSManaged var day: NSDate
	@NSManaged var data: NSData
	
	class func dataFromInfo(moc: NSManagedObjectContext, record: CKRecord) -> DiningDay {
		var request = NSFetchRequest(entityName: "DiningDay")
		
		let recordDay = comparisonDate(record.objectForKey("Day") as! NSDate)
		request.predicate = NSPredicate(format: "day == %@", recordDay)
		
		// might want to delete this? not sure if it would prevent updates
		if let fetchResults = moc.executeFetchRequest(request, error: nil) as? [DiningDay] {
			for result in fetchResults {
				if result.data == record.objectForKey("Data") as! NSData {
					return result
				}
			}
		}
		
		var newItem = NSEntityDescription.insertNewObjectForEntityForName("DiningDay", inManagedObjectContext: moc) as! DiningDay
		// put in new processing to grab the hours...
		
		newItem.data = record.objectForKey("Data") as! NSData
		newItem.day = recordDay
		
		NSNotificationCenter.defaultCenter().postNotificationName("NewDayInfoAdded", object: nil, userInfo:["newItem":newItem])
		
		return newItem
	}
}

class QuickMenu: NSManagedObject {
	@NSManaged var data: NSData
	
	class func dataFromInfo(moc: NSManagedObjectContext, record: CKRecord) -> QuickMenu {
		var request = NSFetchRequest(entityName: "QuickMenu")
		let newData = record.objectForKey("Data") as! NSData
		
		// might want to delete this? not sure if it would prevent updates
		if let fetchResults = moc.executeFetchRequest(request, error: nil) as? [QuickMenu] {
			for result in fetchResults {
				if result.data == newData {
					return result
				}
			}
		}
		
		var newItem = NSEntityDescription.insertNewObjectForEntityForName("QuickMenu", inManagedObjectContext: moc) as! QuickMenu
		// put in new processing to grab the hours...
		
		newItem.data = newData
		NSNotificationCenter.defaultCenter().postNotificationName("QuickInfoUpdated", object: nil, userInfo:["quickInfo":newItem])
		
		return newItem
	}
}

class Food: NSManagedObject {
	/// All the information for the entire food
	@NSManaged var data: NSData
	
	@NSManaged var favorite: Bool
	/// Notify at start of day if seen
		@NSManaged var notify: Bool
	
	@NSManaged var date: NSDate // for servings
	@NSManaged var servings: Int16
	
	class func foodFromInfo(moc: NSManagedObjectContext, food: FoodInfo) -> Food {
		var request = NSFetchRequest(entityName: "Food")
		
		if let fetchResults = moc.executeFetchRequest(request, error: nil) as? [Food] {
			for result in fetchResults {
				if result.info().recipe == food.recipe {
					result.checkDate()
					return result
				}
			}
		}
		
		var newItem = NSEntityDescription.insertNewObjectForEntityForName("Food", inManagedObjectContext: moc) as! Food
		newItem.data = NSJSONSerialization.dataWithJSONObject(food.dictFromObject(), options: .allZeros, error: nil)!
		newItem.favorite = false
		newItem.notify = false
		newItem.date = comparisonDate(NSDate())
		newItem.servings = 0
		
		return newItem
	}
	
	func checkDate() {
		let compareDate = comparisonDate(NSDate())
		
		let dateComponents = components(compareDate)
		let resultComponents = components(date)
		
		if !(dateComponents.weekOfYear == resultComponents.weekOfYear && dateComponents.weekday == resultComponents.weekday) {
			date = compareDate
			servings = 0
		}
	}
	
	private func components(date: NSDate) -> NSDateComponents {
		return currCal.components(.CalendarUnitWeekOfYear | .CalendarUnitWeekday, fromDate: date)
	}
	
	func info() -> FoodInfo {
		return FoodInfo(dict: NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil) as! Dictionary<String, AnyObject>)
	}
}
