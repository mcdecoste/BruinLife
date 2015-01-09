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

enum NutrientDisplayType {
	case oneMain // bold
	case doubleMain // both bold
	case doublePlain // both regular
	case twoMain // first bold
	case oneSub // not bold (replacing twoSub)
	case empty // since no nils possible in tuples
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
	
	var notificationTimeText: String?
	var notificationCell: FoodNotificationTableViewCell?
	
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func setFood(food: MainFoodInfo, date: NSDate, meal: MealType, place: RestaurantInfo) {
		self.food = food
		self.date = date
		self.meal = meal
		self.place = place
		alertHall = "When \(place.hall.displayName((foodVC?.isHall)!)) Opens (\(place.openTime.displayString()))"
		// set reminder time based on whether there is a saved reminder for that time
		notificationTimeText = alertNever
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
			return 3
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
			return Nutrient.rowPairs[indexPath.row].0 == .oneSub ? smallCellHeight : cellHeight
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
			if indexPath.row == reminderRow {
				notificationCell = tableView.dequeueReusableCellWithIdentifier(reminderCellID) as? FoodNotificationTableViewCell
				
				if notificationCell?.textLabel?.text == nil {
					notificationCell?.textLabel?.text = "Remind Me"
				}
				notificationCell?.detailTextLabel?.text = notificationTimeText
				notificationCell?.detailTextLabel?.adjustsFontSizeToFitWidth = true
				notificationCell?.detailTextLabel?.minimumScaleFactor = 0.4
				return notificationCell!
			} else {
				let needsStepper = indexPath.row == servingRow
				
				var cell = tableView.dequeueReusableCellWithIdentifier(personalCellID) as UITableViewCell
				cell.selectionStyle = .None
				
				switch indexPath.row {
				case favoriteRow:
					cell.textLabel?.text = "Favorite Food"
				case servingRow:
					cell.textLabel?.text = servingText()
				default:
					cell.textLabel?.text = ""
				}
				
				if needsStepper {
					var stepper = UIStepper()
					stepper.value = Double(numberOfServings)
					stepper.maximumValue = 16
					stepper.addTarget(self, action: "stepperChanged:", forControlEvents: .ValueChanged)
					cell.accessoryView = stepper
				} else {
					var switcher = UISwitch()
					switcher.setOn(favorited, animated: false)
					switcher.addTarget(self, action: "favoriteChanged:", forControlEvents: .ValueChanged) //  : "reminderChanged:"
					cell.accessoryView = switcher
				}
				
				return cell
			}
		case nutritionSection:
			var cell = tableView.dequeueReusableCellWithIdentifier(nutrientCellID) as NutritionTableViewCell
			
			var cellType: NutrientDisplayType = .empty
			var nutrientLeft: Nutrient = .Cal
			var nutrientRight: Nutrient = .FatCal
			(cellType, nutrientLeft, nutrientRight) = Nutrient.rowPairs[indexPath.row]
			
			var leftIndex = (Nutrient.allRawValues as NSArray).indexOfObject(nutrientLeft.rawValue)
			var rightIndex = (Nutrient.allRawValues as NSArray).indexOfObject(nutrientRight.rawValue)
			var nutrientListingLeft = food.nutrition[leftIndex]
			var nutrientListingRight = food.nutrition[rightIndex]
			
			cell.frame.size = CGSize(width: (nutriTable?.frame.width)!, height: self.tableView(nutriTable!, heightForRowAtIndexPath: indexPath))
			cell.backgroundColor = .clearColor()
			cell.selectionStyle = .None
			cell.setInformation((type: cellType, left: nutrientListingLeft, right: nutrientListingRight))
			cell.setServingCount(numberOfServings)
			
			return cell
		default:
			return tableView.dequeueReusableCellWithIdentifier(ingredientCellID) as UITableViewCell
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		if indexPath.section == personalSection && indexPath.row == reminderRow {
			showNotificationActionSheet()
			
		}
	}
	
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
	
	func servingsNumberChanged(count: Int) {
		numberOfServings = count
		
		nutritionHeader?.setServingsCount(numberOfServings)
		for cell in (nutriTable?.visibleCells() as [UITableViewCell]) {
			if let cellPath = nutriTable?.indexPathForCell(cell) {
				if cellPath.section == nutritionSection {
					(cell as NutritionTableViewCell).setServingCount(numberOfServings)
				}
			}
		}
	}
	
	func favoriteChanged(sender: UISwitch) {
		favorited = sender.on
	}
	
	func stepperChanged(sender: UIStepper) {
		numberOfServings = Int(sender.value)
		
		nutritionHeader?.setServingsCount(numberOfServings)
		for cell in (nutriTable?.visibleCells() as [UITableViewCell]) {
			if let cellPath = nutriTable?.indexPathForCell(cell) {
				if cellPath.section == nutritionSection {
					(cell as NutritionTableViewCell).setServingCount(numberOfServings)
				}
				
				if cellPath.section == personalSection && cellPath.row == servingRow {
					cell.textLabel?.text = servingText()
				}
			}
		}
	}
	
	func servingText() -> String {
		var addendum = numberOfServings == 1 ? "" : "s"
		return "\(numberOfServings) Serving\(addendum)"
	}
	
	
	// MARK: Action Sheets
	func showNotificationActionSheet() {
		var actionSheet = UIActionSheet(title: "When would you like to be reminded?", delegate: self, cancelButtonTitle: alertCancel, destructiveButtonTitle: alertNever, otherButtonTitles: alertMorningFull, alertHall)
		actionSheet.showInView(foodVC?.view)
	}
	
	// MARK: UIActionSheetDelegate
	func actionSheet(actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
		switch actionSheet.buttonTitleAtIndex(buttonIndex) {
		case alertNever:
			notificationTimeText = alertNever
			removeNotification()
		case alertMorningFull: // , alertMeal
			notificationTimeText = alertMorning
			addNotification(Time(hour: 9, minute: 0).timeDateForDate(date)!)
		case alertHall:
			notificationTimeText = place.openTime.displayString()
			addNotification(place.openTime.timeDateForDate(date)!)
		case alertCancel:
			println("Cancelling")
		default:
			println("ERROR")
		}
		
		nutriTable?.reloadRowsAtIndexPaths([NSIndexPath(forRow: reminderRow, inSection: personalSection)], withRowAnimation: .Fade)
	}
	
	// Remove any existing notification
	func removeNotification() {
		// check if we even have one
		var notifs = UIApplication.sharedApplication().scheduledLocalNotifications as Array<UILocalNotification>
		for notif in notifs {
			println(notif.alertBody)
			println(notif.description)
		}
	}
	
	/// Add a new notification or modify an old one
	func addNotification(date: NSDate) {
		// check if already exists
		
		
		// TEST RUN
		var notif = UILocalNotification()
		notif.fireDate = NSDate(timeIntervalSinceNow: 60)
		notif.alertBody = "\(place.hall.displayName((foodVC?.isHall)!)) has \(food.name) for \(meal.rawValue)"
//		notif.alertAction = "Show me boba"
		notif.timeZone = .defaultTimeZone()
		notif.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
		UIApplication.sharedApplication().scheduleLocalNotification(notif)
		
		
		
		/*
		// Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = pickerDate;
    localNotification.alertBody = self.itemText.text;
    localNotification.alertAction = @"Show me the item";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
		*/
		
	}
	
	func notificationDescriptoin() -> String {
		return ""
	}
	
	func typeForFireTime(time: NSDate) -> String {
		return ""
	}
}
