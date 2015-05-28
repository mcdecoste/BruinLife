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
/// Used for Food Identification (Recipe Number)
let notificationRecipeID: String = "NotificationRecipeID"
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
var displayStr: String = { return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as! String }()
/// Version number of application
var versionStr: String = { return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String }()
/// Build number of application
var buildStr: String = { return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String }()

func comparisonDate(date: NSDate = NSDate()) -> NSDate {
	return currCal.startOfDayForDate(date)
}

func comparisonDate(daysInFuture: Int) -> NSDate {
	return currCal.dateByAddingUnit(.CalendarUnitDay, value: daysInFuture, toDate: comparisonDate(), options: nil)!
}

func color(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) -> UIColor {
	return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
}

func plural(count: Int, singular: String, plural: String, prefix: String = "", suffix: String = "", showForZero: Bool = true) -> String {
	switch count {
	case 0:
		return showForZero ? "\(prefix)\(count) \(plural)\(suffix)" : ""
	case 1:
		return "\(prefix)\(count) \(singular)\(suffix)"
	default:
		return "\(prefix)\(count) \(plural)\(suffix)"
	}
}

/// Returns the most likely Meal given the time
var currentMeal: MealType { get { return currentMealOpt ?? .LateNight } }
var currentMealOpt: MealType? {
	get {
		var hour = currCal.component(.CalendarUnitHour, fromDate: NSDate())
	
		if hour <= 3 { return .LateNight }
		if hour <= 11 { return .Breakfast }
		if hour <= 16 { return .Lunch }
		if hour <= 20 { return .Dinner }
		return nil
	}
}

func daysInFuture(date: NSDate) -> Int {
	return currCal.components(.CalendarUnitDay, fromDate: comparisonDate(date: NSDate()), toDate: comparisonDate(date: date), options: .allZeros).day
}

func deserialized(data: NSData) -> Dictionary<String, AnyObject> {
	return deserializedOpt(data) ?? [:]
}

func deserializedOpt(data: NSData) -> Dictionary<String, AnyObject>? {
	return NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil) as? Dictionary<String, AnyObject>
}

func serialize(object: Serializable) -> NSData {
	return NSJSONSerialization.dataWithJSONObject(object.dictFromObject(), options: .allZeros, error: nil) ?? NSData()
}