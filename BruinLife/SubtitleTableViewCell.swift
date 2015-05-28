//
//  NotificationTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/18/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		textLabel?.numberOfLines = 0
		textLabel?.lineBreakMode = .ByWordWrapping
	}
}

class NotificationTableViewCell: SubtitleTableViewCell {
	var foodInfo: Dictionary<String, String> = [:] {
		didSet {
			if let name = foodInfo[notificationFoodID], meal = foodInfo[notificationMealID], place = foodInfo[notificationPlaceID], time = foodInfo[notificationTimeID] {
				textLabel?.text = name
				detailTextLabel?.text = "\(meal) at \(place). Reminding at \(time)"
			}
		}
	}
}

class FavoriteTableViewCell: SubtitleTableViewCell {
	var food: Food? {
		didSet {
			textLabel?.text = food?.info.name
		}
	}
}

class ServingsDisplayTableViewCell: SubtitleTableViewCell {
	var servingText: String {
		get {
			return plural(Int(food?.servings ?? 0), "Serving", "Servings")
		}
	}
	
	var food: Food? {
		didSet {
			textLabel?.text = food!.info.name
			detailTextLabel?.text = servingText
			if let stepper = accessoryView as? UIStepper {
				stepper.value = Double(food?.servings ?? 0)
			}
		}
	}
	
	var numServings: Int {
		get {
			return Int(food?.servings ?? 0)
		}
		set {
			food?.servings = Int16(newValue)
			detailTextLabel?.text = servingText
			if let food = food {
				NSNotificationCenter.defaultCenter().postNotificationName("ServingChange", object: food)
			}
		}
	}
	
	var stepper: UIStepper? {
		get {
			return accessoryView as? UIStepper
		}
		set {
			accessoryView = newValue
		}
	}
	
	override func setup() {
		super.setup()
		
		var step = UIStepper()
		step.addTarget(self, action: "stepperChanged:", forControlEvents: .ValueChanged)
		step.maximumValue = 16
		stepper = step
	}
	
	func stepperChanged(sender: UIStepper) {
		numServings = Int(sender.value)
	}
	
	override func didTransitionToState(state: UITableViewCellStateMask) {
		if state == UITableViewCellStateMask.DefaultMask {
			stepper?.enabled = true
		}
	}
	
	override func willTransitionToState(state: UITableViewCellStateMask) {
		if state == UITableViewCellStateMask.ShowingDeleteConfirmationMask {
			stepper?.enabled = false
		}
	}
}