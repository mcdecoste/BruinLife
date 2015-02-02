//
//  FoodViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/9/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit
import CoreData

struct NutriTableDisplay {
	var name: String
	var indentLevel: Int
	var measures: Array<String>
}

enum NutrientDisplayType {
	case oneMain // bold
	case doubleMain // both bold
	case doublePlain // both regular
	case twoMain // first bold
	case oneSub // not bold (replacing twoSub)
	case empty // since no nils possible in tuples
}

enum ReminderCase: Int {
	case beforeAll = 0
	case beforeMorning = 1
	case beforeOpen = 2
	case afterAll = 3
}

class FoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {
	private let nutrientCellID = "nutrition"
	private let ingredientCellID = "ingredient"
	private let personalCellID = "personal"
	private let reminderCellID = "reminder"
	private let servingCellID = "serving"
	private let cellHeight: CGFloat = 44.0
	private let smallCellHeight: CGFloat = 36.0
	private let nutritionGap: CGFloat = 2
	private let headerGap: CGFloat = 8
	
	private let descriptionSection: Int = 0
	private let personalSection: Int = 1
		private let favoriteRow: Int = 0
		private let reminderRow: Int = 1
		private let servingRow: Int = 2
	private let nutritionSection: Int = 2
	private let ingredientSection: Int = 3
	
	private let realWidth: CGFloat = 280
	private let realHeight: CGFloat = 460
	
	private let baseWidth: CGFloat = 280 * 0.9
	private let baseHeight: CGFloat = 460 * 0.5
	
	private let darkGreyTextColor = UIColor(white: 0.3, alpha: 1.0)
	private let lightGreyTextColor = UIColor(white: 0.45, alpha: 1.0)
	
	private let morningTime = Time(hour: 9, minute: 0)
	
	/// date displayed food is being offered (based on food table view controller)
	var date: NSDate = NSDate()
	var meal: MealType = .Breakfast
	var place: RestaurantInfo = RestaurantInfo(hall: .DeNeve)
	
	var food: MainFoodInfo = MainFoodInfo(name: "", recipe: "000000", type: .Regular)
	var foodLabel = UILabel()
	var typeLabel = UILabel()
	
	var nutriTable: UITableView?
	
	var nutritionHeader: NutritionHeaderView? // for updating on the fly (hopefully)
	
	var ingredientsLabel = UILabel()
	var descriptionLabel = UILabel()
	var nutritionLabel = UILabel()
	var personalLabel = UILabel()
	
	// track information
	var numberOfServings = 0
	var favorited = false
	var reminding = false
	
	var foodVC: FoodTableViewController?
	
	let alertCancel = "Cancel"
	let alertNever = "Never"
	let alertMorningFull = "Start of Day (9:00 AM)"
	let alertMorning = "Start of Day"
	var alertHall = ""
	
	var notificationCell: FoodNotificationTableViewCell?
	
	// CORE DATA
	lazy var managedObjectContext: NSManagedObjectContext? = {
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		if let moc = appDelegate.managedObjectContext { return moc }
		else { return nil }
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		view.frame.size = preferredContentSize()
		nutriTable = UITableView(frame: view.frame, style: .Plain)
		
		view.addSubview(foodLabel)
		view.addSubview(typeLabel)
		view.addSubview(nutriTable!)
		nutriTable?.delegate = self
		nutriTable?.dataSource = self
		nutriTable?.separatorStyle = .None
		
		nutriTable?.registerClass(NutritionTableViewCell.self, forCellReuseIdentifier: nutrientCellID)
		nutriTable?.registerClass(UITableViewCell.self, forCellReuseIdentifier: ingredientCellID)
		nutriTable?.registerClass(UITableViewCell.self, forCellReuseIdentifier: personalCellID)
		nutriTable?.registerClass(FoodNotificationTableViewCell.self, forCellReuseIdentifier: reminderCellID)
		nutriTable?.registerClass(NutritionHeaderView.self, forHeaderFooterViewReuseIdentifier: nutrientCellID)
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchFoods()
	}
	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func reminderCase() -> ReminderCase {
		let openDate = place.openTime.timeDateForDate(date)
		let morningDate = morningTime.timeDateForDate(date)
		
		var timeCase = (morningDate?.timeIntervalSinceNow)! > 0 ? 0 : 2
		timeCase += (openDate?.timeIntervalSinceNow)! > 0 ? 0 : 1
		
		return ReminderCase(rawValue: timeCase)!
	}
	
	func hideReminders() -> Bool {
		return reminderCase() == ReminderCase.afterAll
	}
	
	// MARK: - Setup
	
	func setFood(food: MainFoodInfo, date: NSDate, meal: MealType, place: RestaurantInfo) {
		self.food = food
		self.date = date
		self.meal = meal
		self.place = place
		alertHall = "When \(place.hall.displayName((foodVC?.isHall)!)) Opens (\(place.openTime.displayString()))"
		// set reminder time based on whether there is a saved reminder for that time
		establishLayout()
	}
	
	func establishLayout() {
		let type = food.type.rawValue
		let country = food.countryCode
		let typeText = (type != "" && country != "") ? "\(country)  •  \(type)" : (country + type)
		
		makeIngredientsLabel()
		makeDescriptionLabel()
		makeNutritionLabel()
		makePersonalLabel()
		
		foodLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		foodLabel.text = food.name
		foodLabel.font = .systemFontOfSize(18)
		foodLabel.textAlignment = .Center
		foodLabel.numberOfLines = 0 // no, not 2
		foodLabel.lineBreakMode = .ByWordWrapping
		foodLabel.sizeToFit()
		foodLabel.center.x = view.center.x
		foodLabel.frame.origin.y = realHeight * 0.015
		
		typeLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		typeLabel.text = typeText
		typeLabel.font = .systemFontOfSize(12)
		typeLabel.textAlignment = .Center
		typeLabel.sizeToFit()
		typeLabel.center.x = view.center.x
		typeLabel.frame.origin.y = foodLabel.frame.maxY
		
		var ntY = typeLabel.frame.maxY + 2
		
		nutriTable?.frame = CGRect(x: 0, y: ntY, width: realWidth, height: realHeight - ntY)
	}
	
	func preferredContentSize() -> CGSize {
		return CGSize(width: realWidth, height: realHeight) // 260 is a little too narrow
	}
	
	// MARK: Label
	
	func makeIngredientsLabel() {
		ingredientsLabel = UILabel()
		ingredientsLabel.frame.size = CGSize(width: view.frame.width * 19/20, height: baseHeight)
		ingredientsLabel.text = "Ingredients: \(food.ingredients)"
		ingredientsLabel.font = .systemFontOfSize(11)
		ingredientsLabel.textColor = darkGreyTextColor
		ingredientsLabel.textAlignment = .Left
		ingredientsLabel.numberOfLines = 0
		ingredientsLabel.lineBreakMode = .ByWordWrapping
		ingredientsLabel.sizeToFit()
		ingredientsLabel.frame.origin.y = 8
		ingredientsLabel.center.x = view.center.x
	}
	
	func makeDescriptionLabel() {
		let hasDescription = food.description != ""
		descriptionLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		descriptionLabel.text = hasDescription ? food.description : "No description available"
		descriptionLabel.font = hasDescription ? .systemFontOfSize(12) : .italicSystemFontOfSize(12)
		descriptionLabel.textColor = hasDescription ? darkGreyTextColor : lightGreyTextColor
		descriptionLabel.textAlignment = .Center
		descriptionLabel.numberOfLines = 0
		descriptionLabel.lineBreakMode = .ByWordWrapping
		descriptionLabel.sizeToFit()
		descriptionLabel.center.x = view.center.x
	}
	
	func makeNutritionLabel() {
		nutritionLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		nutritionLabel.text = "Nutrition Facts"
		nutritionLabel.font = .boldSystemFontOfSize(20)
		nutritionLabel.textAlignment = .Left
		nutritionLabel.sizeToFit()
		nutritionLabel.frame.origin = CGPoint(x: 8, y: headerGap)
	}
	
	func makePersonalLabel() {
		personalLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		personalLabel.text = "Bruin Tracks"
		personalLabel.font = .boldSystemFontOfSize(20)
		personalLabel.textAlignment = .Left
		personalLabel.sizeToFit()
		personalLabel.frame.origin = CGPoint(x: 8, y: headerGap)
	}

	// MARK: - Table View Data Source
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// Return the number of sections.
		var numSections = 3 // description, servings, and nutrition
		if food.ingredients != "" { numSections++ }
		return numSections
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case nutritionSection:
			return Nutrient.rowPairs.count
		case personalSection:
			var baseNum = 3
			if !representsToday(date) { baseNum-- }
			if hideReminders() { baseNum-- }
			return baseNum
		default:
			return 1
		}
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch section {
		case nutritionSection:
			return nutritionLabel.frame.maxY
		case personalSection:
			return personalLabel.frame.maxY
		default:
			return 0
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch indexPath.section {
		case nutritionSection:
			return Nutrient.rowPairs[indexPath.row].type == .oneSub ? smallCellHeight : cellHeight
		case ingredientSection:
			return ingredientsLabel.frame.maxY + 4
		case descriptionSection:
			return descriptionLabel.frame.maxY
		default:
			return cellHeight
		}
	}
	
	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		switch section {
		case nutritionSection:
			if nutritionHeader == nil {
				nutritionHeader = nutriTable?.dequeueReusableHeaderFooterViewWithIdentifier(nutrientCellID) as NutritionHeaderView?
			}
			nutritionHeader?.frame.size = CGSize(width: (nutriTable?.frame.width)!, height: self.tableView(nutriTable!, heightForHeaderInSection: section))
			nutritionHeader?.setServingsCount(numberOfServings)
			return nutritionHeader
		default:
			var header = UIView(frame: CGRect(x: 0, y: 0, width: (nutriTable?.frame.width)!, height: self.tableView(tableView, heightForHeaderInSection: section)))
			header.backgroundColor = .whiteColor()
			header.addSubview(personalLabel)
			return header
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.section {
		case descriptionSection, ingredientSection:
			var cell = tableView.dequeueReusableCellWithIdentifier(ingredientCellID) as UITableViewCell
			var label = indexPath.section == descriptionSection ? descriptionLabel : ingredientsLabel
			
			for subview in cell.subviews {
				if subview.isMemberOfClass(UILabel.self) { subview.removeFromSuperview() }
			}
			
			cell.textLabel?.text = nil
			cell.selectionStyle = .None
			cell.accessoryView = nil
			cell.addSubview(label)
			return cell
		case personalSection:
			var row = personalRow(indexPath.row)
			
			if row == reminderRow {
				notificationCell = tableView.dequeueReusableCellWithIdentifier(reminderCellID) as? FoodNotificationTableViewCell
				
				if notificationCell?.textLabel?.text == nil {
					notificationCell?.textLabel?.text = "Remind Me"
				}
				notificationCell?.detailTextLabel?.text = notificationDisplay()
				notificationCell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
				notificationCell?.detailTextLabel?.minimumScaleFactor = 0.4
				return notificationCell!
			} else {
				let needsStepper = row == servingRow
				
				var cell = tableView.dequeueReusableCellWithIdentifier(personalCellID) as UITableViewCell
				cell.selectionStyle = .None
				
				if needsStepper {
					cell.textLabel?.text = servingText()
					
					var stepper = UIStepper()
					stepper.value = Double(numberOfServings)
					stepper.maximumValue = 16
					stepper.addTarget(self, action: "stepperChanged:", forControlEvents: .ValueChanged)
					cell.accessoryView = stepper
				} else {
					cell.textLabel?.text = "Favorite Food"
					
					var switcher = UISwitch()
					switcher.setOn(favorited, animated: false)
					switcher.addTarget(self, action: "favoriteChanged:", forControlEvents: .ValueChanged)
					cell.accessoryView = switcher
				}
				
				return cell
			}
		case nutritionSection:
			var cell = tableView.dequeueReusableCellWithIdentifier(nutrientCellID) as NutritionTableViewCell
			
			let allRaw = Nutrient.allRawValues as NSArray
			let cellInfo = Nutrient.rowPairs[indexPath.row]
			
			var nutrientListingLeft = food.nutrition[allRaw.indexOfObject(cellInfo.left.rawValue)]
			var nutrientListingRight = food.nutrition[allRaw.indexOfObject(cellInfo.right.rawValue)]
			
			cell.frame.size.width = nutriTable!.frame.width
			cell.backgroundColor = .clearColor()
			cell.selectionStyle = .None
			cell.setInformation((type: cellInfo.type, left: nutrientListingLeft, right: nutrientListingRight))
			cell.setServingCount(numberOfServings)
			
			return cell
		default:
			return tableView.dequeueReusableCellWithIdentifier(ingredientCellID) as UITableViewCell
		}
	}
	
	func personalRow(row: Int) -> Int {
		var theRow = row
		if theRow >= reminderRow && hideReminders() { theRow++ }
		
		return theRow
	}
	
	// MARK: Table View Delegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if indexPath.section == personalSection && indexPath.row == reminderRow {
			showNotificationActionSheet()
		}
	}
	
	// MARK: - Core Data
	
	func fetchFoods() {
		var fetchRequest = NSFetchRequest(entityName: "Food")
		
		if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Food] {
			for result in fetchResults {
				if result.info().recipe == food.recipe {
					var theFood = fetchResults[0]
					numberOfServings = Int(theFood.servings)
					favorited = theFood.favorite
				}
			}
		}
	}
	
	func save() {
		var error: NSError?
		if managedObjectContext!.save(&error) {
			if error != nil { println(error?.localizedDescription) }
		}
	}
	
	func favoriteChanged(sender: UISwitch) {
		favorited = sender.on
		
		// Core Data
		if let moc = managedObjectContext {
			var theFood = Food.foodFromInfo(moc, food: food)
			theFood.favorite = favorited
			save()
		}
	}
	
	func stepperChanged(sender: UIStepper) {
		numberOfServings = Int(sender.value)
		
		nutritionHeader?.setServingsCount(numberOfServings)
		for cell in (nutriTable?.visibleCells() as [UITableViewCell]) {
			if let cellPath = nutriTable?.indexPathForCell(cell) {
				// update nutritional cells
				if cellPath.section == nutritionSection {
					(cell as NutritionTableViewCell).setServingCount(numberOfServings)
				}
				
				// update the serving count cell
				if cellPath.section == personalSection && personalRow(cellPath.row) == servingRow {
					cell.textLabel?.text = servingText()
				}
			}
		}
		
		// Core Data
		if let moc = managedObjectContext {
			var theFood = Food.foodFromInfo(moc, food: food)
			theFood.servings = Int16(numberOfServings)
			save()
		}
	}
	
	// MARK: - Action Sheets
	
	func showNotificationActionSheet() {
		var actionSheet: UIActionSheet?
		
		let hasReminder = getNotification() != nil
		
		let noChangeText = hasReminder ? alertCancel : alertNever
		let removeText: String? = hasReminder ? alertNever : nil
		
		// determine what kind of action sheet to show
		switch reminderCase() {
		case .beforeAll: // before both
			actionSheet = UIActionSheet(title: "When would you like to be reminded?", delegate: self, cancelButtonTitle: noChangeText, destructiveButtonTitle: removeText, otherButtonTitles: alertMorningFull, alertHall)
		case .beforeMorning: // before morning, after opening
			actionSheet = UIActionSheet(title: "When would you like to be reminded?", delegate: self, cancelButtonTitle: noChangeText, destructiveButtonTitle: removeText, otherButtonTitles: alertMorningFull)
		case .beforeOpen: // after morning, before opening
			actionSheet = UIActionSheet(title: "When would you like to be reminded?", delegate: self, cancelButtonTitle: noChangeText, destructiveButtonTitle: removeText, otherButtonTitles: alertHall)
		default: // after both
			actionSheet = UIActionSheet(title: "There are no reminder options.", delegate: self, cancelButtonTitle: alertCancel, destructiveButtonTitle: removeText) // had to customize this one
		}
		
		actionSheet?.showInView(foodVC?.view)
	}
	
	// MARK: UIActionSheetDelegate
	func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
		switch actionSheet.buttonTitleAtIndex(buttonIndex) {
		case alertNever:
			removeNotification()
		case alertMorningFull:
			addNotification(morningTime.timeDateForDate(date)!)
		case alertHall:
			addNotification(place.openTime.timeDateForDate(date)!)
		case alertCancel:
			println("Cancelling")
		default:
			println("ERROR")
		}
		
		nutriTable?.reloadRowsAtIndexPaths([NSIndexPath(forRow: reminderRow, inSection: personalSection)], withRowAnimation: .Fade)
	}
	
	// MARK: - Notifications
	
	func notificationString() -> String {
		return "\(place.hall.displayName((foodVC?.isHall)!)) has \(food.name) for \(meal.rawValue) (\(place.openTime.displayString()) - \(place.closeTime.displayString()))"
	}
	
	// Remove any existing notification
	func removeNotification() {
		// using while should remove all possible matches
		while let notification = getNotification() {
			UIApplication.sharedApplication().cancelLocalNotification(notification)
		}
	}
	
	func getNotification() -> UILocalNotification? {
		var notifications = UIApplication.sharedApplication().scheduledLocalNotifications as Array<UILocalNotification>
		for not in notifications {
			if let value = (not.userInfo as [String : String])[notificationID] {
				if value == identifierForFood() { return not }
			}
		}
		
		return nil
	}
	
	/// Add a new notification or modify an old one.
	func addNotification(date: NSDate) {
		// if already exists, delete it
		removeNotification()
		
		// build it up
		var notif = UILocalNotification()
		notif.timeZone = .defaultTimeZone()
		notif.fireDate = date // NSDate(timeIntervalSinceNow: 30)
		notif.alertBody = notificationString()
		notif.timeZone = .defaultTimeZone()
		
		var information = [String:String]()
		information[notificationID] = identifierForFood()
		information[notificationFoodID] = food.name
		information[notificationPlaceID] = place.hall.displayName((foodVC?.isHall)!)
		information[notificationDateID] = weekdayForFood()
		information[notificationMealID] = meal.rawValue
		information[notificationHoursID] = "\(place.openTime.displayString()) until \(place.closeTime.displayString())"
		
		let fireCal = NSCalendar.currentCalendar().components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: notif.fireDate!)
		let fireTime = Time(hour: fireCal.hour, minute: fireCal.minute)
		information[notificationTimeID] = fireTime.displayString()
		notif.userInfo = information
		
		// Sanity check: only add notifications for the future
		if notif.fireDate!.timeIntervalSinceNow > 0 {
			UIApplication.sharedApplication().scheduleLocalNotification(notif)
		}
	}
	
	// MARK: Helpers
	
	func servingText() -> String {
		var addendum = numberOfServings == 1 ? "" : "s"
		return "\(numberOfServings) Serving\(addendum)"
	}
	
	func identifierForFood() -> String {
		let currCal = NSCalendar.currentCalendar()
		let components = currCal.components(.CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
		
		return "\(components.month)/\(components.day) - \(place.hall.displayName((foodVC?.isHall)!)) - \(meal.rawValue) - \(food.name)"
	}
	
	func weekdayForFood() -> String {
		let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		return weekdays[NSCalendar.currentCalendar().components(.CalendarUnitWeekday, fromDate: date).weekday - 1]
	}
	
	func displayForFireDate(date: NSDate) -> String {
		var components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
		
		return Time(hour: components.hour, minute: components.minute).displayString()
	}
	
	func notificationDisplay() -> String {
		if let notification = getNotification() {
			return displayForFireDate(notification.fireDate!)
		} else {
			return alertNever
		}
	}
}
