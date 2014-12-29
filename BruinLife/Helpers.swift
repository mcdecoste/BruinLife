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
	
	if hour <= 3 { return .LateNight }
	if hour <= 10 { return .Breakfast }
	if hour <= 15 { return .Lunch }
	if hour <= 20 { return .Dinner }
	return .LateNight
}

func orderedMeals(meals: Array<MealType>) -> Array<MealType> {
	var mealByValue: Dictionary<MealType, Int> = [.Breakfast : 1, .Lunch : 2, .Brunch : 2, .Dinner : 3, .LateNight : 4]
	var remainingMeals = meals
	var orderedMeals: Array<MealType> = []
	
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