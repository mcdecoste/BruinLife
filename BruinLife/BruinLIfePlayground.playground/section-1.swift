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


//var imageView = UIImageView(image: imageWithView(cal))
//var effect = UIBlurEffect(style: .Light) // Light, Dark, ExtraLight
//var blurView = UIVisualEffectView(effect: effect)
//var vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: effect))


//blurView.frame = CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 100))

//blurView.contentView.addSubview(vibrancyView)
//vibrancyView.contentView.addSubview(imageView)

//var blurringView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
//
//blurView.frame = blurringView.bounds
//vibrancyView.frame = blurView.bounds
//
//blurringView.addSubview(imageView)
//blurringView.insertSubview(blurView, aboveSubview: imageView)

//blurView.contentView.addSubview(imageView)
//blurView

var currentDate = NSDate(timeIntervalSinceNow: 12*60*60)
formatter.dateFormat = "H:m a"
var timeString = formatter.stringFromDate(currentDate)
var weekOfYear = NSCalendar.currentCalendar().component(.CalendarUnitWeekOfYear, fromDate: currentDate)
var dayOfWeekCalUnit = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitWeekday, fromDate: currentDate)
var hour = NSCalendar.currentCalendar().component(.CalendarUnitHour, fromDate: currentDate)
var minute = NSCalendar.currentCalendar().component(.CalendarUnitMinute, fromDate: currentDate)



/*
NSError * error = nil;
NSString * htmlString = @"<html><body><p>Test</body></html>";

NSXMLDocument * doc =
[[NSXMLDocument alloc]
initWithXMLString: htmlString
options: NSXMLDocumentTidyHTML
error: &error];
NSLog(@"Error is: %@", error);
NSLog(@"Doc is: %@", doc);
NSLog(@"Root element is: %@", [doc rootElement]);
NSLog(@"Root element's children are: %@", [[doc rootElement] children]);



var error: NSError? = nil
var foodURL = NSURL(string: "http://menu.ha.ucla.edu/foodpro/default.asp?location=07&date=1%2F8%2F2015")
//var htmlString = NSString(contentsOfURL: foodURL, encoding: NSUTF8StringEncoding, error: error)
var htmlString = NSString(contentsOfURL: foodURL!, encoding: NSUTF8StringEncoding, error: &error)
error?.description
*/


var greenColor: UIColor = .greenColor()
var redColor: UIColor = .redColor()
UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1.0)

import UIKit
import QuartzCore
import CoreGraphics

class CircleDisplay: UIView {
	var centralLabel: UILabel
	
	var backgroundLayer: CAShapeLayer
	var foregroundLayer: CAShapeLayer
	
	var nutrition: NutritionListing?
	var showingAmount: Bool = true
	
	var progress: CGFloat = 0.0
	var lineWidth: CGFloat = 0.0
	
	let tickWidthRatio: CGFloat = 0.3
	let progressWidthRatio: CGFloat = 2.0 // must be larger than 1
	
	override init(frame: CGRect) {
		centralLabel = UILabel(frame: frame)
		
		backgroundLayer = CAShapeLayer()
		foregroundLayer = CAShapeLayer()
		super.init(frame: frame)
		
		setup()
	}
	
	required init(coder aDecoder: NSCoder) {
		centralLabel = UILabel(coder: aDecoder)
		
		backgroundLayer = CAShapeLayer(coder: aDecoder)
		foregroundLayer = CAShapeLayer(coder: aDecoder)
		super.init(coder: aDecoder)
		
		setup()
	}
	
	func setup() {
		backgroundColor = .clearColor()
		
		// label
		centralLabel.text = ""
		centralLabel.font = UIFont.systemFontOfSize(14)
		centralLabel.sizeToFit()
		centralLabel.center = center
		
		// layers time
		lineWidth = max(0.025 * frame.width, 1.0)
		var contentsScale: CGFloat = UIScreen.mainScreen().scale
		
		backgroundLayer.frame = bounds
		backgroundLayer.contentsScale = contentsScale
		backgroundLayer.strokeColor = tintColor.CGColor
		backgroundLayer.fillColor = (backgroundColor?.CGColor)!
		backgroundLayer.lineCap = kCALineCapRound // change?
		backgroundLayer.lineWidth = lineWidth
		
		foregroundLayer.frame = bounds
		foregroundLayer.contentsScale = contentsScale
		foregroundLayer.strokeColor = tintColor.CGColor
		foregroundLayer.fillColor = UIColor.clearColor().CGColor // or nil
		foregroundLayer.lineCap = kCALineCapSquare
		foregroundLayer.lineWidth = lineWidth * progressWidthRatio
		
		layer.addSublayer(backgroundLayer)
		layer.addSublayer(foregroundLayer)
		addSubview(centralLabel)
	}
	
	// MARK: Setters
	func setNutrition(nutrition: NutritionListing) {
		self.nutrition = nutrition
		
		setProgress(CGFloat((self.nutrition?.percent)!) / 100)
		updateDisplayText()
	}
	
	func handleTap() {
		if (nutrition?.type.hasDVpercentage())! {
			showingAmount = !showingAmount
			updateDisplayText()
		}
	}
	
	func setProgress(progress: CGFloat) {
		self.progress = progress
		
		let startAngle = CGFloat(3*M_PI_2)
		let endAngle = startAngle + (2 * CGFloat(M_PI) * self.progress)
		let radius = (bounds.width - (3 * lineWidth)) / 2
		
		var processPath = UIBezierPath()
		processPath.lineCapStyle = kCGLineCapButt
		processPath.lineWidth = lineWidth
		processPath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
		
		foregroundLayer.path = processPath.CGPath
		
		setNeedsDisplay()
	}
	
	func setLineWidth(width: CGFloat) {
		self.lineWidth = width
		
		backgroundLayer.lineWidth = width
		foregroundLayer.lineWidth = width * progressWidthRatio
	}
	
	func updateDisplayText() {
		centralLabel.removeFromSuperview()
		
		let text = showingAmount ? (self.nutrition?.measure)! + (self.nutrition?.unit)! : "\((self.nutrition?.percent)!)%"
		println(text)
		centralLabel.text = text
		centralLabel.sizeToFit()
		centralLabel.center = center
		
		addSubview(centralLabel)
	}
}

class NutritionListing {
	var type: Nutrient = .Cal
	var unit: String
	var measure: String = ""
	var percent: Int = 0 // out of 100
	
	init(type: Nutrient, measure: String) {
		self.type = type
		self.measure = measure
		self.unit = type.unit()
		self.percent = dailyValue()
	}
	
	internal func dailyValue() -> Int {
		if let dailyValue = Nutrient.allDailyValues[(find(Nutrient.allValues, self.type))!] {
			return Int(100.0 * ((measure as NSString).floatValue) / Float(dailyValue))
		}
		return 0
	}
}

enum Nutrient: String { // , Equatable
	case Cal = "Calories"
	case FatCal = "Calories From Fat"
	case TotFat = "Total Fat"
	case SatFat = "Saturated Fat"
	case TransFat = "Trans Fat"
	case Chol = "Cholesterol"
	case Sodium = "Sodium"
	case TotCarb = "Total Carbs"
	case DietFiber = "Dietary Fiber"
	case Sugar = "Sugars"
	case Protein = "Protein"
	case VitA = "Vitamin A"
	case VitC = "Vitamin C"
	case Calcium = "Calcium"
	case Iron = "Iron"
	
	func unit() -> String {
		switch self {
		case .Cal, .FatCal:
			return ""
		case .TotFat, .SatFat, .TransFat, .TotCarb, .DietFiber, .Sugar, .Protein:
			return "g"
		case .Chol, .Sodium:
			return "mg"
		case .VitA, .VitC, .Calcium, .Iron:
			return "%"
		}
	}
	
	static let allValues: Array<Nutrient> = [.Cal, .FatCal, .TotFat, .SatFat, .TransFat, .Chol, .Sodium, .TotCarb, .DietFiber, .Sugar, .Protein, .VitA, .VitC, .Calcium, .Iron]
	static let allRawValues = Nutrient.allValues.map { (nut: Nutrient) -> String in return nut.rawValue }
	static let allMatchingValues: Array<String> = ["Calories", "Fat Cal.", "Total Fat", "Saturated Fat", "Trans Fat", "Cholesterol", "Sodium", "Total Carbohydrate", "Dietary Fiber", "Sugars", "Protein", "Vitamin A", "Vitamin C", "Calcium", "Iron"]
	internal static let allDailyValues: Array<Int?> = [nil, nil, 65, 20, nil, 300, 1500, 130, 40, nil, nil, 100, 100, 100, 100]
	
	static func typeForName(name: String) -> Nutrient? {
		var index = 0
		var matchingValues = Nutrient.allMatchingValues
		for value in matchingValues {
			if name.rangeOfString(value) != nil { break }
			index++
		}
		if index > matchingValues.count-1 { return nil }
		return Nutrient.allValues[index]
	}
	
	func hasDVpercentage() -> Bool {
		var index = (Nutrient.allRawValues as NSArray).indexOfObject(rawValue)
		return Nutrient.allDailyValues[index] != nil
	}
}

var circle: CircleDisplay = CircleDisplay(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
circle.setNutrition(NutritionListing(type: .TotFat, measure: "23"))


