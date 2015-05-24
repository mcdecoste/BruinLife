//
//  ServingsDisplayTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/15/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class ServingsDisplayTableViewCell: UITableViewCell {
	var expanded: Bool = false
	var controller: ServingsTableViewController?
	
	var servingText: String {
		get {
			var servings = Int(food?.servings ?? 0)
			var addendum = servings == 1 ? "" : "s"
			return "\(servings) Serving\(addendum)"
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
		let count = Int(sender.value)
		food?.servings = Int16(count)
		detailTextLabel?.text = servingText
		
		controller?.changeServing(self, count: count)
	}
}
