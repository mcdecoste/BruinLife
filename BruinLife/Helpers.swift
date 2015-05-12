//
//  Helpers.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/16/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

/// Used to determine notification identity
let notificationID: String = "NotificationID"
/// Used for text label in NotificationTableViewController
let notificationFoodID: String = "NotificationFoodID"
/// Used for detail text label in NotificationTableViewController with Meal
let notificationPlaceID: String = "NotificationPlaceID"
/// Used for detail text label in NotificationTableViewController with Place
let notificationMealID: String = "NotificationMealID"
/// Used to determine section in NotificationTableViewController
let notificationDateID: String = "NotificationDateID" // should pair up to "EEEE, h:m a" OR "M/d h:m a"
/// Used for detail text label in NotificationTableViewController
let notificationTimeID: String = "NotificationTimeID"
/// Used to describe when the hall is open
let notificationHoursID: String = "NotificationHoursID"

let tableBackgroundColor = color(239, 239, 244)
let currCal = NSCalendar.currentCalendar()

/// Name, version, and build of application
var versionDisplayString: String {
	get {
		return "\(displayStr) \(versionStr) (\(buildStr))"
	}
}
/// Displayed name of application
var displayStr: String {
get {
	return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as! String
}
}
/// Version number of application
var versionStr: String {
get {
	return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
}
}
/// Build number of application
var buildStr: String {
get {
	return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
}
}

func comparisonDate(date: NSDate = NSDate()) -> NSDate {
	return currCal.startOfDayForDate(date)
}

func comparisonDate(daysInFuture: Int) -> NSDate {
	return currCal.dateByAddingUnit(.CalendarUnitDay, value: daysInFuture, toDate: comparisonDate(), options: nil)!
}

func color(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) -> UIColor {
	return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
}

/// Returns the most likely Meal given the time
var currentMeal: MealType {
	get {
		var hour = currCal.component(.CalendarUnitHour, fromDate: NSDate())
		
		if hour <= 3 { return .LateNight }
		if hour <= 11 { return .Breakfast }
		if hour <= 16 { return .Lunch }
		if hour <= 20 { return .Dinner }
		return .LateNight
	}
}

func daysInFuture(date: NSDate) -> Int {
	let today = currCal.component(.CalendarUnitDay, fromDate: NSDate())
	let selectedDay = currCal.component(.CalendarUnitDay, fromDate: date)
	return abs(today - selectedDay)
}

func orderedMeals(meals: Array<MealType>) -> Array<MealType> {
	var mealByValue: Dictionary<MealType, Int> = [.Breakfast : 1, .Lunch : 2, .Brunch : 2, .Dinner : 3, .LateNight : 4]
	var remainingMeals = meals
	var orderedMeals = [MealType]()
	
	while remainingMeals.count > 0 {
		var nextMeal = remainingMeals[0]
		for meal in remainingMeals {
			if mealByValue[meal] < mealByValue[nextMeal] { nextMeal = meal }
		}
		
		orderedMeals.append(nextMeal)
		remainingMeals.removeAtIndex((find(remainingMeals, nextMeal))!)
	}
	
	return orderedMeals
}