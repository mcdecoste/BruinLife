//
//  Helpers.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/16/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

var timeInDay: Double = 24*60*60
var dateFormatWeekday = "EEEE"

/// Returns the most likely Meal given the time
func currentMeal() -> MealType {
	var hour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: NSDate())
	
	if hour <= 10 { return .Breakfast }
	if hour <= 3 { return .Lunch }
	if hour <= 8 { return .Dinner }
	return .LateNight
}