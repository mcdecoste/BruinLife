//
//  SwipeModel.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/15/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

enum DaysOfWeekNames: String {
	case Mon = "Monday"
	case Tues = "Tuesday"
	case Wed = "Wednesday"
	case Thur = "Thursday"
	case Fri = "Friday"
	case Sat = "Saturday"
	case Sun = "Sunday"
}

enum WeekNames: String {
	case One = "Week One"
	case Two = "Week Two"
	case Three = "Week Three"
	case Four = "Week Four"
	case Five = "Week Five"
	case Six = "Week Six"
	case Seven = "Week Seven"
	case Eight = "Week Eight"
	case Nine = "Week Nine"
	case Ten = "Week Ten"
	case Final = "Finals Week"
}

enum QuarterType: String {
	case Fall = "Fall"
	case Winter = "Winter"
	case Spring = "Spring"
}

enum MealPlanType: String {
	case BP19 = "Bruin Premier 19"
	case BP14 = "Bruin Premier 14"
	case G19 = "Gold 19"
	case G14 = "Gold 14"
	case C11 = "Cub 11"
}

class MealPlan {
	let ws19: Array<Int> = [19, 16, 13, 10, 7, 4, 2, 0]
	let ws14: Array<Int> = [14, 12, 10, 8, 6, 4, 2, 0]
	let ws11: Array<Int> = [11, 9, 8, 6, 5, 3, 1, 0]
	
	var plan: MealPlanType = .BP19
	var weeklySwipes: Array<Int> = [19, 16, 13, 10, 7, 4, 2, 0]
	var rollover = true
	
	/// This is the only way you should ever change the plan
	func setPlan(plan: MealPlanType) {
		self.plan = plan
		
		rollover = (self.plan == .BP19 || self.plan == .BP14)
		
		switch self.plan {
		case .BP19, .G19:
			weeklySwipes = ws19
		case .BP14, .G14:
			weeklySwipes = ws14
		default:
			weeklySwipes = ws11
		}
	}
	
	/// Returns the number of swipes you should have left after swiping for a meal
	func swipesLeft(week: Int, day: Int, meal: MealType) -> Int {
		var swipesPerMeal = [MealType.Breakfast : 0]
		
		switch weeklySwipes[day] - weeklySwipes[day + 1] {
		case 3:
			swipesPerMeal = [.LateNight : 0, .Dinner : 0, .Lunch : 1, .Brunch : 2, .Breakfast : 2]
		case 2:
			swipesPerMeal = [.LateNight : 0, .Dinner : 0, .Lunch : 1, .Brunch : 1, .Breakfast : 1]
		default: // 0 or 1
			swipesPerMeal = [.LateNight : 0, .Dinner : 0, .Lunch : 0, .Brunch : 0, .Breakfast : 0]
		}
		
		var swipes = weeklySwipes[day + 1]
		
		if plan == .BP19 || plan == .BP14 {
			swipes += (10 - week) * weeklySwipes[0]
		}
		
		return swipesPerMeal[meal]! + swipes
	}
}

class SwipeModel: NSObject {
	let startWeeks: Array <(Int, QuarterType)> = [(1, .Winter), (14, .Spring), (41, .Fall)]
	let plans: Array<MealPlanType> = [.C11, .G14, .G19, .BP14, .BP19]
	let weeks: Array<WeekNames> = [.One, .Two, .Three, .Four, .Five, .Six, .Seven, .Eight, .Nine, .Ten, .Final]
	let daysOfWeek: Array<DaysOfWeekNames> = [.Mon, .Tues, .Wed, .Thur, .Fri, .Sat, .Sun]
	
	var mealPlan = MealPlan()
	var selectedWeek = 0
	var selectedDay = 0
	var selectedMeal = MealType.Lunch
	var currentQuarter: QuarterType? = nil
	
	override init() {
		super.init()
		mealPlan.setPlan(.BP19)
		resetToCurrent()
	}
	
	/// Returns the current week and quarter (since they're related)
	func currentWeekAndQuarter() -> (Int, QuarterType?) {
		var cal = NSCalendar.currentCalendar()
		var weekOfYear = cal.component(.CalendarUnitWeekOfYear, fromDate: NSDate())
		
		for (startWeek, quarter) in startWeeks {
			var currWeek = weekOfYear - startWeek
			if currWeek < 11 {
				return (currWeek, quarter)
			}
		}
		
		return (0, nil) // default values
	}
	
	func currentDayOfWeek() -> Int {
		// find current day of week
		var formatter = NSDateFormatter()
		formatter.dateFormat = dateFormatWeekday
		var dayOfWeek = formatter.stringFromDate(NSDate())
		
		var dowIndex = 0
		// find index for day of week
		for (index, dayLabel) in enumerate(daysOfWeek) {
			if dayLabel.rawValue == dayOfWeek {
				dowIndex = index
				break
			}
		}
		return dowIndex
	}
	
	func swipesForSelectedDay() -> Int {
		return mealPlan.swipesLeft(selectedWeek, day: selectedDay, meal: .Dinner)
	}
	func swipesForSelectedDayAndTime() -> Int {
		return mealPlan.swipesLeft(selectedWeek, day: selectedDay, meal: selectedMeal)
	}
	
	func resetToCurrent() {
		(selectedWeek, currentQuarter) = currentWeekAndQuarter()
		selectedDay = currentDayOfWeek()
		selectedMeal = currentMeal()
	}
	
	func sameAsCurrent() -> Bool {
		var (currWeek, currQuar) = currentWeekAndQuarter()
		var currDay = currentDayOfWeek()
		var currMeal = currentMeal()
		
		return selectedWeek == currWeek && selectedDay == currDay && selectedMeal == currMeal
	}
}
