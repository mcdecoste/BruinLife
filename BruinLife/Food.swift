//
//  Favorite.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/7/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

//import UIKit
//import CoreData
//
//class Favorite: NSManagedObject {
//	// inherent, unchanging properties (replace with reference to FoodItem?)
//	@NSManaged var name: String
//	@NSManaged var recipe: String
//	
//	// mutable properties
////	@NSManaged var favorited: Bool
////	@NSManaged var servings: Int
//	
//	/// returns existing entity if it exists, creates one if it has to.
//	class func favoriteFromInformation(moc: NSManagedObjectContext, name: String, recipe: String) -> (created: Bool, entity: Favorite) {
//        if let fetchResults = moc.executeFetchRequest(NSFetchRequest(entityName: "Favorite"), error: nil) as? [Favorite] {
//			for result in fetchResults {
//				if result.recipe == recipe {
//					return (created: false, entity: result)
//				}
//			}
//        }
//		
//		let newItem = NSEntityDescription.insertNewObjectForEntityForName("Favorite", inManagedObjectContext: moc) as Favorite
//		newItem.name = name
//		newItem.recipe = recipe
//		
//		// we have no reason to believe
////		newItem.favorited = false
////		newItem.servings = 0
//		
//		return (created: true, entity: newItem)
//	}
//}
//
//class Servings: NSManagedObject {
//	// inherent, unchanging properties (replace with reference to FoodItem?)
//	@NSManaged var name: String
//	@NSManaged var recipe: String
//	
//	// mutable properties
//	//	@NSManaged var favorited: Bool
//	@NSManaged var servings: Int
//	@NSManaged var date: NSDate // should reset on each new day
//	
//	/// returns existing entity if it exists, creates one if it has to.
//	class func servingsFromInformation(moc: NSManagedObjectContext, name: String, recipe: String, servings: Int) -> (created: Bool, entity: Servings) {
//		if let fetchResults = moc.executeFetchRequest(NSFetchRequest(entityName: "Servings"), error: nil) as? [Servings] {
//			for result in fetchResults {
//				if result.recipe == recipe {
//					// clear out old servings listings
//					if result.date == NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: nil)! {
//						result.servings = servings // includ this?
//						return (created: false, entity: result)
//					} else {
//						// It's an old listing. Delete it!
//						moc.deleteObject(result)
//					}
//				}
//			}
//		}
//		
//		let newItem = NSEntityDescription.insertNewObjectForEntityForName("Servings", inManagedObjectContext: moc) as Servings
//		newItem.name = name
//		newItem.recipe = recipe
//		newItem.servings = servings
//		newItem.date = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: NSDate(), options: nil)!
//		
//		return (created: true, entity: newItem)
//	}
//}

import UIKit
import CoreData

class Food: NSManagedObject {
	@NSManaged var name: String
	@NSManaged var recipe: String
	
	@NSManaged var favorite: Bool
	
	@NSManaged var date: NSDate // for servings
	@NSManaged var servings: Int16
	
	class func foodFromInformation(moc: NSManagedObjectContext, name: String, recipe: String) -> (created: Bool, entity: Food) {
		if let fetchResults = moc.executeFetchRequest(NSFetchRequest(entityName: "Food"), error: nil) as? [Food] {
			for result in fetchResults {
				if result.recipe == recipe {
					let currentCalendar = NSCalendar.currentCalendar()
					
					let date = comparisonDate(NSDate())
					let bool1 = currentCalendar.component(.CalendarUnitWeekOfYear, fromDate: date) == currentCalendar.component(.CalendarUnitWeekOfYear, fromDate: result.date)
					let bool2 = currentCalendar.component(.CalendarUnitWeekday, fromDate: date) == currentCalendar.component(.CalendarUnitWeekday, fromDate: result.date)
					
					if !(bool1 && bool2) {
						println(result.date)
						println(date)
						
						result.date = date
						result.servings = 0
					}
					
					return (created: false, entity: result)
				}
			}
		}
		
		let newItem = NSEntityDescription.insertNewObjectForEntityForName("Food", inManagedObjectContext: moc) as Food
		newItem.name = name
		newItem.recipe = recipe
		
		newItem.favorite = false
		newItem.date = NSDate()
		newItem.servings = 0
		
		return (created: true, entity: newItem)
	}
	
	class func comparisonDate(date: NSDate) -> NSDate {
		return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: nil)!
	}
}
