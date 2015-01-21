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
	
	var nameLabel = UILabel()
	var stepper = UIStepper()
	var servingLabel = UILabel()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
		layout()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		layout()
	}
	
	func changeFood(food: Food) {
		nameLabel.text = food.info().name
		stepper.value = Double(food.servings)
		servingLabel.text = servingText(Int(food.servings))
	}
	
	func layout() {
		nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		nameLabel.font = .systemFontOfSize(17)
		nameLabel.numberOfLines = 0
		nameLabel.lineBreakMode = .ByWordWrapping
		contentView.addSubview(nameLabel)
		
		stepper.setTranslatesAutoresizingMaskIntoConstraints(false)
		stepper.addTarget(self, action: "stepperChanged:", forControlEvents: .ValueChanged)
		stepper.maximumValue = 16
		contentView.addSubview(stepper)
		
		servingLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		servingLabel.font = .systemFontOfSize(15)
		servingLabel.textColor = UIColor(white: 0.3, alpha: 1)
		servingLabel.textAlignment = .Center
		contentView.addSubview(servingLabel)
		
		// Auto Layout
		contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: stepper, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: -4))
		
		addConstraint("H:|-16-[name]-(>=5)-[serving]-(>=16)-|")
		addConstraint("H:|-16-[name]-5-[stepper]-16-|")
		addConstraint("V:|-(>=10)-[serving]-3-[stepper]-(>=10)-|", option: .AlignAllCenterX)
		addConstraint("V:|-(>=15)-[name]-(>=15)-|")
	}
	
	func addConstraint(format: String, option: NSLayoutFormatOptions = .allZeros) {
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: option, metrics: nil, views: ["name" : nameLabel, "stepper" : stepper, "serving" : servingLabel]))
	}
	
	func servingText(count: Int) -> String {
		var addendum = count == 1 ? "" : "s"
		return "\(count) Serving\(addendum)"
	}
	
	func stepperChanged(sender: UIStepper) {
		let count = Int(sender.value)
		servingLabel.text = servingText(count)
		
		controller?.changeServing(self, count: count)
	}
}
