//
//  FoodViewController.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/9/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

struct NutriTableDisplay {
	var name: String
	var indentLevel: Int
	var measures: Array<String>
}

enum ReminderCase: Int {
	case beforeAll = 0
	case beforeMorning = 1
	case beforeOpen = 2
	case afterAll = 3
}

class FoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {
	private let nutrientCellID = "nutrition", ingredientCellID = "ingredient", personalCellID = "personal", reminderCellID = "reminder", servingCellID = "serving"
	private let nutrientHeaderID = "nutrientHeader", headerID = "header"
	private let cellHeight: CGFloat = 44.0, smallCellHeight: CGFloat = 36.0
	private let nutritionGap: CGFloat = 2, headerGap: CGFloat = 8
	
	private let descriptionSection: Int = 0
	private let personalSection: Int = 1
	
	private let favoriteRow: Int = 0
	private var reminderRow: Int {
		get {
			return shouldHideReminders ? -1 : 1
		}
	}
	private var servingRow: Int {
		get {
			return shouldHideReminders ? 1 : 2
		}
	}
	private let nutritionSection: Int = 2
	private let ingredientSection: Int = 3
	
	private let realWidth: CGFloat = 290, realHeight: CGFloat = 460
	private let baseWidth: CGFloat = 290 * 0.9, baseHeight: CGFloat = 460 * 0.5
	
	private let darkGreyTextColor = UIColor(white: 0.3, alpha: 1.0), lightGreyTextColor = UIColor(white: 0.45, alpha: 1.0)
	
	private let morningTime = Time(hour: 9, minute: 0)
	
	/// date displayed food is being offered (based on food table view controller)
	var date: NSDate = NSDate()
	var meal: MealType = .Breakfast
	var place: RestaurantBrief = RestaurantBrief()
	
	var food: FoodInfo = FoodInfo()
	var side: FoodInfo? = FoodInfo()
	var foodLabel = UILabel(), typeLabel = UILabel()
	
	var nutriTable: UITableView?
	
//	var nutritionHeader: NutritionHeaderView? // for updating on the fly (hopefully)
	
	var ingredientsLabel = UILabel(), descriptionLabel = UILabel(), nutritionLabel = UILabel(),  personalLabel = UILabel()
	
	// track information
	var numberOfServings = 0
	var favorited = false
	var reminding = false
	
	let alertCancel = "Cancel", alertNever = "Never", alertMorningFull = "Start of Day (9:00 AM)", alertMorning = "Start of Day"
	var alertHall: String {
		get {
			return "When \(place.hall.displayName(popDelegate.isHall)) Opens (\(place.openTime.displayString))"
		}
	}
	
	private var notificationCell: FoodNotificationTableViewCell {
		get {
			let cell = nutriTable!.dequeueReusableCellWithIdentifier(reminderCellID) as! FoodNotificationTableViewCell
			
			cell.textLabel?.text = "Remind Me"
			cell.detailTextLabel?.text = notificationDisplay
			cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
			cell.detailTextLabel?.minimumScaleFactor = 0.4
			return cell
		}
	}
	
	private var favoriteCell: UITableViewCell {
		get {
			var cell = nutriTable?.dequeueReusableCellWithIdentifier(personalCellID) as! UITableViewCell
			cell.selectionStyle = .None
			cell.textLabel?.text = "Favorite Food"
			
			var switcher = UISwitch()
			switcher.setOn(favorited, animated: false)
			switcher.addTarget(self, action: "favoriteChanged:", forControlEvents: .ValueChanged)
			cell.accessoryView = switcher
			
			return cell
		}
	}
	
	private var servingCell: UITableViewCell {
		get {
			var cell = nutriTable?.dequeueReusableCellWithIdentifier(personalCellID) as! UITableViewCell
			cell.selectionStyle = .None
			cell.textLabel?.text = servingText
			
			var stepper = UIStepper()
			stepper.value = Double(numberOfServings)
			stepper.maximumValue = 16
			stepper.addTarget(self, action: "stepperChanged:", forControlEvents: .ValueChanged)
			cell.accessoryView = stepper
			
			return cell
		}
	}
	
	private var prefContentSize: CGSize {
		get {
			return CGSize(width: realWidth, height: realHeight)
		}
	}
	
	private var popDelegate: FoodTableViewController {
		get {
			return popoverPresentationController?.delegate as! FoodTableViewController
		}
	}
	
	private var servingText: String {
		get {
			return plural(numberOfServings, "Serving", "Servings")
		}
	}
	
	private var notificationDisplay: String {
		get {
			if let notification = notification {
				return displayForFireDate(notification.fireDate!)
			} else {
				return alertNever
			}
		}
	}
	
	private var reminderCase: ReminderCase {
		get {
			let openDate = place.openTime.timeDateForDate(date)
			let morningDate = morningTime.timeDateForDate(date)
			
			var timeCase = morningDate.timeIntervalSinceNow > 0 ? 0 : 2
			timeCase += openDate.timeIntervalSinceNow > 0 ? 0 : 1
			
			return ReminderCase(rawValue: timeCase)!
		}
	}
	
	private var shouldHideReminders: Bool { get { return reminderCase == .afterAll } }
	
	private var notification: UILocalNotification? {
		get { return CloudManager.sharedInstance.localNotification(food, date: date, place: place.hall, isHall: popDelegate.isHall, meal: meal) }
	}
	
	// MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		view.frame.size = prefContentSize
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
		nutriTable?.registerClass(NutritionHeaderView.self, forHeaderFooterViewReuseIdentifier: nutrientHeaderID)
		nutriTable?.registerClass(GeneralHeaderView.self, forHeaderFooterViewReuseIdentifier: headerID)
		
		preferredContentSize = prefContentSize
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		fetchFoods()
	}
	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: - Setup
	
	func setFood(food: FoodInfo, side: FoodInfo? = nil, date: NSDate, meal: MealType, place: RestaurantBrief) {
		self.food = food
		self.side = side
		self.date = date
		self.meal = meal
		self.place = place
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
	
	// MARK:- Labels
	
	private func makeIngredientsLabel() {
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
	
	private func makeDescriptionLabel() {
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
	
	private func makeNutritionLabel() {
		nutritionLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		nutritionLabel.text = "Nutrition Facts"
		nutritionLabel.font = .boldSystemFontOfSize(20)
		nutritionLabel.textAlignment = .Left
		nutritionLabel.sizeToFit()
		nutritionLabel.frame.origin = CGPoint(x: 8, y: headerGap)
	}
	
	private func makePersonalLabel() {
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
			if !currCal.isDateInToday(date) { baseNum-- }
			if shouldHideReminders { baseNum-- }
			return baseNum
		default:
			return 1
		}
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch section {
		case nutritionSection, personalSection:
			return tableView.headerViewForSection(section)?.frame.height ?? 32 //nutritionLabel.frame.maxY
		default:
			return 0
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch indexPath.section {
		case nutritionSection:
			let isOneSub = Nutrient.rowPairs[indexPath.row].type == NutrientDisplayType.oneSub
			return isOneSub ? smallCellHeight : cellHeight
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
			if let header = nutriTable?.dequeueReusableHeaderFooterViewWithIdentifier(nutrientHeaderID) as? NutritionHeaderView {
//				header.frame.size = header.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize)
				header.servingsCount = numberOfServings
				return header
			}
			return nil
		default:
			return nutriTable?.dequeueReusableHeaderFooterViewWithIdentifier(headerID) as? GeneralHeaderView
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.section {
		case descriptionSection, ingredientSection:
			var cell = tableView.dequeueReusableCellWithIdentifier(ingredientCellID) as! UITableViewCell
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
			switch indexPath.row {
			case reminderRow:
				return notificationCell
			case servingRow:
				return servingCell
			default:
				return favoriteCell
			}
		case nutritionSection:
			return nutritionCell(indexPath.row)
		default:
			return tableView.dequeueReusableCellWithIdentifier(ingredientCellID) as! UITableViewCell
		}
	}
	
	private func nutritionCell(row: Int) -> NutritionTableViewCell {
		var cell = nutriTable!.dequeueReusableCellWithIdentifier(nutrientCellID) as! NutritionTableViewCell
		cell.frame.size.width = nutriTable!.frame.width
		cell.backgroundColor = .clearColor()
		cell.selectionStyle = .None
		
		let cellInfo = Nutrient.rowPairs[row]
		let leftValues: (type: String, information: NutritionListing) = (type: cellInfo.left.rawValue, information: food.nutrition[cellInfo.left]!)
		var rightValues: (type: String, information: NutritionListing) = (type: cellInfo.right.rawValue, information: food.nutrition[cellInfo.right]!)
		
		cell.setInformation(cellInfo.type, left: leftValues, right: rightValues)
		cell.setServingCount(numberOfServings)
		
		return cell
	}
	
	// MARK: Table View Delegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if indexPath.section == personalSection && indexPath.row == reminderRow {
			showNotificationActionSheet()
		}
	}
	
	// MARK: - Core Data
	
	private func fetchFoods() {
		(numberOfServings, favorited) = CloudManager.sharedInstance.foodDetails(food.recipe)
	}
	
	func favoriteChanged(sender: UISwitch) {
		CloudManager.sharedInstance.changeFavorite(food, favorite: sender.on)
	}
	
	func stepperChanged(sender: UIStepper) {
		numberOfServings = Int(sender.value)
		
		// View changes
		(nutriTable!.headerViewForSection(nutritionSection) as! NutritionHeaderView).servingsCount = numberOfServings
		for path in nutriTable!.indexPathsForVisibleRows() as! [NSIndexPath] {
			switch (path.section, path.row) {
			case (nutritionSection, _):
				(nutriTable!.cellForRowAtIndexPath(path) as! NutritionTableViewCell).setServingCount(numberOfServings)
			case (personalSection, servingRow):
				nutriTable!.cellForRowAtIndexPath(path)!.textLabel?.text = servingText
			default:
				continue
			}
		}
		
		// Model changes
		CloudManager.sharedInstance.changeEaten(food, servings: numberOfServings)
	}
	
	// MARK: - Action Sheets
	
	private func showNotificationActionSheet() {
		let hasReminder = notification != nil
		
		let noChangeText = hasReminder ? alertCancel : alertNever
		let removeText: String? = hasReminder ? alertNever : nil
		
		// determine what kind of action sheet to show
		switch reminderCase {
		case .beforeAll: // before both
			UIActionSheet(title: "When would you like to be reminded?", delegate: self, cancelButtonTitle: noChangeText, destructiveButtonTitle: removeText, otherButtonTitles: alertMorningFull, alertHall).showInView(popDelegate.view)
		case .afterAll:
			return
		default:
			let other = reminderCase == .beforeMorning ? alertMorningFull : alertHall
			UIActionSheet(title: "When would you like to be reminded?", delegate: self, cancelButtonTitle: noChangeText, destructiveButtonTitle: removeText, otherButtonTitles: other).showInView(popDelegate.view)
		}
	}
	
	// MARK: UIActionSheetDelegate
	func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
		switch actionSheet.buttonTitleAtIndex(buttonIndex) {
		case alertNever:
			removeNotification()
		case alertMorningFull:
			addNotification(date, hour: morningTime.hour, minute: morningTime.minute)
		case alertHall:
			addNotification(date, hour: place.openTime.hour, minute: place.openTime.minute)
		case alertCancel:
			return
		default:
			return
		}
		
		(nutriTable?.cellForRowAtIndexPath(NSIndexPath(forRow: reminderRow, inSection: personalSection)) as? FoodNotificationTableViewCell)?.detailTextLabel?.text = notificationDisplay
	}
	
	// MARK: - Notifications
	
	private func removeNotification() {
		CloudManager.sharedInstance.removeNotification(food, date: date, place: place, isHall: popDelegate.isHall, meal: meal)
	}
	
	/// Add a new notification or modify an old one.
	private func addNotification(date: NSDate, hour: Int? = nil, minute: Int? = nil) {
		removeNotification()
		CloudManager.sharedInstance.addNotification(date, mealType: meal, placeBrief: place, info: food, fireHour: hour, fireMin: minute)
	}
	
	// MARK: Helpers
	
	private func displayForFireDate(date: NSDate) -> String {
		var components = currCal.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: date)
		return Time(hour: components.hour, minute: components.minute).displayString
	}
}
