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


class CalendarView: UIView {
	var monthTitle: UILabel
	var dayTitle: UILabel
	
	let monthRatio: CGFloat = 0.5
	let dayRatio: CGFloat = 0.8
	
	override init(frame: CGRect) {
		monthTitle = UILabel(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height * monthRatio)))
		monthTitle.textColor = .redColor()
		monthTitle.textAlignment = .Center
		monthTitle.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
		
		var dayHeight = frame.height * dayRatio
		dayTitle = UILabel(frame: CGRect(x: frame.minX, y: frame.maxY - dayHeight, width: frame.width, height: dayHeight))
		dayTitle.textAlignment = .Center
		//		dayTitle.font = UIFont.systemFontOfSize(UIFont.systemFontSize() + 12)
		dayTitle.font = UIFont(name: "HelveticaNeue-Thin", size: UIFont.systemFontSize() + 12)
		
		super.init(frame: frame)
		
		addSubview(monthTitle)
		addSubview(dayTitle)
	}
	
	required init(coder aDecoder: NSCoder) {
		var frame = CGRectZero
		
		monthTitle = UILabel(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height * monthRatio)))
		monthTitle.textColor = .redColor()
		
		dayTitle = UILabel(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height * dayRatio)))
		
		super.init(coder: aDecoder)
		
		addSubview(monthTitle)
		addSubview(dayTitle)
	}
}

var cal = CalendarView(frame: CGRect(x: 0, y: 0, width: 48, height: 66))
cal.monthTitle.text = "Sept."
cal.dayTitle.text = "30"
cal


func imageWithView(view: UIView) -> UIImage {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
	view.layer.renderInContext(UIGraphicsGetCurrentContext())
	var image = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	return image
}

