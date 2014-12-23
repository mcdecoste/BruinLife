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
	
	static let allValues = [Mon, Tues, Wed, Thur, Fri, Sat, Sun]
	static let allRawValues = [Mon.rawValue, Tues.rawValue, Wed.rawValue, Thur.rawValue, Fri.rawValue, Sat.rawValue, Sun.rawValue]
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
	
	static let allValues = [One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Final]
//	static let allRawValues = [One.rawValue, Two.rawValue, Three.rawValue, Four.rawValue, Five.rawValue, Six.rawValue, Seven.rawValue, Eight.rawValue, Nine.rawValue, Ten.rawValue, Final.rawValue]
}

enum QuarterType: String {
	case Fall = "Fall"
	case Winter = "Winter"
	case Spring = "Spring"
	
	static let allValues = [Fall, Winter, Spring]
//	static let allRawValues = [Fall.rawValue, Winter.rawValue, Spring.rawValue]
	static let startValues = [(1, Winter), (14, Spring), (41, Fall)]
}

enum MealPlanType: String {
	case BP19 = "Bruin Premier 19"
	case BP14 = "Bruin Premier 14"
	case G19 = "Gold 19"
	case G14 = "Gold 14"
	case C11 = "Cub 11"
	
	static let allValues = [C11, G14, G19, BP14, BP19]
//	static let allRawValues = [C11.rawValue, G14.rawValue, G19.rawValue, BP14.rawValue, BP19.rawValue]
	
	func hasRollover() -> Bool {
		return self == .BP19 || self == .BP14
	}
	
	func weeklySwipes() -> Array<Int> {
		switch self {
		case .BP19, .G19:
			return [19, 16, 13, 10, 7, 4, 2, 0]
		case .BP14, .G14:
			return [14, 12, 10, 8, 6, 4, 2, 0]
		default:
			return [11, 9, 8, 6, 5, 3, 1, 0]
		}
	}
	
	func mealSwipeDict(swipes: Int) -> Dictionary<MealType, Int> {
		switch swipes {
		case 3:
			return [.LateNight : 0, .Dinner : 0, .Lunch : 1, .Brunch : 2, .Breakfast : 2]
		case 2:
			return [.LateNight : 0, .Dinner : 0, .Lunch : 1, .Brunch : 1, .Breakfast : 1]
		default:
			return [.LateNight : 0, .Dinner : 0, .Lunch : 0, .Brunch : 0, .Breakfast : 0]
		}
	}
	
	func swipesLeft(week: Int, day: Int, meal: MealType) -> Int {
		let weeklySwipes = self.weeklySwipes()
		let weekRemainder = weeklySwipes[day + 1]
		let rolloverSwipes = self.hasRollover() ? (10 - week) * self.weeklySwipes()[0] : 0
		return mealSwipeDict(weeklySwipes[day] - weeklySwipes[day + 1])[meal]! + weekRemainder + rolloverSwipes
	}
}

class SwipeModel: NSObject {
	let startWeeks = QuarterType.startValues
	let plans = MealPlanType.allValues
	let weeks = WeekNames.allValues
	let daysOfWeek = DaysOfWeekNames.allValues
	
	var mealPlan: MealPlanType = .BP19
	var selectedWeek = 0
	var selectedDay = 0
	var selectedMeal = MealType.Lunch
	var currentQuarter: QuarterType? = nil
	
	override init() {
		super.init()
		resetToCurrent()
	}
	
	/// Returns the current week and quarter (since they're related)
	func currentWeekAndQuarter() -> (week: Int, quarter: QuarterType?) {
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
		var sameWeek = selectedWeek == currentWeekAndQuarter().week
		var sameDay = selectedDay == currentDayOfWeek()
		var sameMeal = selectedMeal == currentMeal()
		return sameWeek && sameDay && sameMeal
	}
}