//
//  Favorite.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/7/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit
import CoreData

class Food: NSManagedObject {
	@NSManaged var name: String
	@NSManaged var recipe: String
	
	@NSManaged var favorite: Bool
	
	@NSManaged var date: NSDate // for servings
	@NSManaged var servings: Int16
	
	@NSManaged var nutrition: String
	@NSManaged var type: String
	
	class func foodFromInfo(moc: NSManagedObjectContext, food: FoodInfo) -> Food {
		var coreFood = foodFromInformation(moc, name: food.name, recipe: food.recipe).entity
		
		coreFood.nutrition = food.nutritionString()
		coreFood.type = food.typeString()
		
		return coreFood
	}
	
	private class func foodFromInformation(moc: NSManagedObjectContext, name: String, recipe: String) -> (created: Bool, entity: Food) {
		if let fetchResults = moc.executeFetchRequest(NSFetchRequest(entityName: "Food"), error: nil) as? [Food] {
			for result in fetchResults {
				if result.recipe == recipe {
					result.checkDate()
					return (created: false, entity: result)
				}
			}
		}
		
		let newItem = NSEntityDescription.insertNewObjectForEntityForName("Food", inManagedObjectContext: moc) as Food
		newItem.name = name
		newItem.recipe = recipe
		
		newItem.favorite = false
		newItem.date = Food.comparisonDate(NSDate())
		newItem.servings = 0
		
		return (created: true, entity: newItem)
	}
	
	class func comparisonDate(date: NSDate) -> NSDate {
		return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: nil)!
	}
	
	func checkDate() {
		let currentCalendar = NSCalendar.currentCalendar()
		let comparisonDate = Food.comparisonDate(NSDate())
		
		let dateComponents = currentCalendar.components(.CalendarUnitWeekOfYear | .CalendarUnitWeekday, fromDate: comparisonDate)
		let resultComponents = currentCalendar.components(.CalendarUnitWeekOfYear | .CalendarUnitWeekday, fromDate: date)
		
		if !(dateComponents.weekOfYear == resultComponents.weekOfYear && dateComponents.weekday == resultComponents.weekday) {
			date = comparisonDate
			servings = 0
		}
	}
	
	func info() -> FoodInfo {
		var food = FoodInfo(name: name, recipe: recipe, type: .Regular) // type reset later
		
		food.setNutrition(nutrition)
		food.setType(type)
		
		return food
	}
}
