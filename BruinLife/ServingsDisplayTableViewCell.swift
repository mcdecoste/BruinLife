//
//  ServingsDisplayTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/15/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class ServingsDisplayTableViewCell: UITableViewCell {
	var controller: ServingsTableViewController?
	
	var servingText: String {
		get {
			var servings = Int(food?.servings ?? 0)
			var addendum = servings == 1 ? "Serving" : "Servings"
			return "\(servings) \(addendum)"
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
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
		layout()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		layout()
	}
	
	func layout() {
		textLabel?.numberOfLines = 0
		textLabel?.lineBreakMode = .ByWordWrapping
		
		var stepper = UIStepper()
		stepper.addTarget(self, action: "stepperChanged:", forControlEvents: .ValueChanged)
		stepper.maximumValue = 16
		accessoryView = stepper
	}
	
	func stepperChanged(sender: UIStepper) {
		numServings = Int(sender.value)
	}
	
	override func didTransitionToState(state: UITableViewCellStateMask) {
		switch state {
		case UITableViewCellStateMask.DefaultMask:
			if let stepper = accessoryView as? UIStepper {
				stepper.enabled = true
			}
		default:
			return
		}
	}
	
	override func willTransitionToState(state: UITableViewCellStateMask) {
		switch state {
		case UITableViewCellStateMask.ShowingDeleteConfirmationMask:
			if let stepper = accessoryView as? UIStepper {
				stepper.enabled = false
			}
		default:
			return
		}
	}
}
