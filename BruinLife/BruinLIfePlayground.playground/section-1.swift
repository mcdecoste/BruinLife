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

var cal = CalendarView(frame: CGRect(x: 0, y: 0, width: 80, height: 66)) // was 48
cal.monthTitle.text = "Sept."
cal.dayTitle.text = "30"
cal.backgroundColor = .whiteColor()


func imageWithView(view: UIView) -> UIImage {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
	view.layer.renderInContext(UIGraphicsGetCurrentContext())
	var image = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	return image
}


/*
NSDate *d = [calendar dateBySettingHour:10 minute:0 second:0 ofDate:[NSDate date] options:0];
 */

//var calendar = NSCalendar.currentCalendar()
//var calendar = NSCalendar.currentCalendar()
//var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar) as NSCalendar?


var imageView = UIImageView(image: imageWithView(cal))
var effect = UIBlurEffect(style: .Light) // Light, Dark, ExtraLight
var blurView = UIVisualEffectView(effect: effect)
var vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: effect))


//blurView.frame = CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100))

blurView.contentView.addSubview(vibrancyView)
//vibrancyView.contentView.addSubview(imageView)

var blurringView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))

blurView.frame = blurringView.bounds
vibrancyView.frame = blurView.bounds

blurringView.addSubview(imageView)
blurringView.insertSubview(blurView, aboveSubview: imageView)

//blurView.contentView.addSubview(imageView)



blurView
