// Playground - noun: a place where people can play

import UIKit

var format1 = "M/d"
var format2 = "MMM d"
var formatter = NSDateFormatter()
formatter.dateFormat = format2;
var date = formatter.stringFromDate(NSDate())

enum MealType : String {
	case Breakfast = "Breakfast"
	case Lunch = "Lunch"
	case Dinner = "Dinner"
	case Brunch = "Brunch"
}

//var formatter = NSDateFormatter()
formatter.dateFormat = "EEE"

formatter.dateFormat = "h:m a"
var string = formatter.stringFromDate(NSDate())

//
var dow = formatter.stringFromDate(NSDate(timeIntervalSinceNow: 5 * 24 * 60 * 60))
var isWeekend = dow == "Sat" || dow == "Sun"
//
var meals: Array<MealType> = isWeekend ? [.Brunch, .Dinner] : [.Breakfast, .Lunch, .Dinner]
var mealTitles: Array<String> = []
//
for item in meals {
	mealTitles.append(item.rawValue)
}

mealTitles



//func imageWithView(view: UIView) -> UIImage {
//	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
//	view.layer.renderInContext(UIGraphicsGetCurrentContext())
//	var image = UIGraphicsGetImageFromCurrentImageContext()
//	UIGraphicsEndImageContext()
//	return image
//}


var currentDate = NSDate(timeIntervalSinceNow: 12*60*60)
formatter.dateFormat = "H:m a"
var timeString = formatter.stringFromDate(currentDate)
var weekOfYear = NSCalendar.currentCalendar().component(.CalendarUnitWeekOfYear, fromDate: currentDate)
var dayOfWeekCalUnit = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitWeekday, fromDate: currentDate)
var hour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: currentDate)
var minute = NSCalendar.currentCalendar().component(.CalendarUnitMinute, fromDate: currentDate)

var isSunday = NSCalendar.currentCalendar().component(.CalendarUnitWeekday, fromDate: NSDate(timeIntervalSinceNow: 6*24*3600))

var components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: NSDate(timeIntervalSinceNow: 2 * 3600))

var componentsHour = components.hour
var componentsMinute = components.minute


NSCalendar.currentCalendar().components(.CalendarUnitDay, fromDate: NSDate()).day
NSCalendar.currentCalendar().components(.CalendarUnitDay, fromDate: NSDate(timeIntervalSinceNow: 23*3600)).day

NSCalendar.currentCalendar().components(.CalendarUnitWeekday, fromDate: NSDate()).weekday

var parts = split("a||||b", { $0 == "|" } )
parts