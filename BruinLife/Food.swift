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
	
	var info: FoodInfo { get { return FoodInfo(dict: deserialized(data)) } }
	
	/// Invalidate servings count if the day has changed.
	func checkDate() {
		let compareDate = comparisonDate()
		if !NSCalendar.currentCalendar().isDate(compareDate, inSameDayAsDate: date) {
			date = compareDate
			servings = 0
		}
	}
}
