//
//  ServingTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/3/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class ServingTableViewCell: UITableViewCell {
	var foodController: FoodViewController?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		finishSetup()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		finishSetup()
	}
	
	func finishSetup() {
		textLabel?.font = .systemFontOfSize(17)
		
		var stepper = UIStepper()
		stepper.addTarget(self, action: "stepperChanged", forControlEvents: .ValueChanged)
		stepper.wraps = false
		stepper.autorepeat = true
		stepper.maximumValue = 16
		stepper.stepValue = 1
		
		accessoryView = stepper
	}
	
	func newlyDisplaying(count: Int, withController controller: FoodViewController) {
		foodController = controller
		(accessoryView as UIStepper).value = Double(count)
		stepperChanged()
	}
	
	func stepperChanged() {
		var count = Int((accessoryView as UIStepper).value)
		
		textLabel?.text = "\(count) Serving" + (count == 1 ? "" : "s")
		
		foodController?.servingsNumberChanged(count)
	}
}
