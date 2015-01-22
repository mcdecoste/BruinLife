//
//  Favorite.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/7/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import CoreData

func comparisonDate(date: NSDate) -> NSDate {
	return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: nil)!
}

class Day: NSManagedObject {
	@NSManaged var date: NSDate
	@NSManaged var string: String
	
	class func foodFromInfo(moc: NSManagedObjectContext, day: DayInfo) -> Day {
		var request = NSFetchRequest(entityName: "Day")
		request.predicate = NSPredicate(format: "date == %@", day.date)
		
		if let fetchResults = moc.executeFetchRequest(request, error: nil) as? [Day] {
			for result in fetchResults {
				return result
			}
		}
		
		var newItem = NSEntityDescription.insertNewObjectForEntityForName("Day", inManagedObjectContext: moc) as Day
		newItem.string = day.formattedString()
		newItem.date = comparisonDate(NSDate())
		
		return newItem
	}
}

class Food: NSManagedObject {
	/// All the information for the entire food
	@NSManaged var foodString: String
	
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
		
		var newItem = NSEntityDescription.insertNewObjectForEntityForName("Food", inManagedObjectContext: moc) as Food
		newItem.foodString = food.foodString()
		
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
		return NSCalendar.currentCalendar().components(.CalendarUnitWeekOfYear | .CalendarUnitWeekday, fromDate: date)
	}
	
	func info() -> FoodInfo {
		return MainFoodInfo.isMain(foodString) ? MainFoodInfo(formattedString: foodString) : FoodInfo(formattedString: foodString)
	}
}
