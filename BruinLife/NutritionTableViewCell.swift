//
//  NutritionTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/10/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class NutritionTableViewCell: UITableViewCell {
	var display: CircleDisplay = CircleDisplay(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
	var nutrition: NutritionListing = NutritionListing(type: .Cal, measure: "0")
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		finishSetup()
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		finishSetup()
	}
	
	func finishSetup() {
		addSubview(display)
	}
	
	func setNutrition(nutrition: NutritionListing) {
		display.frame.origin.x = frame.size.width - display.frame.width - 6
		display.center.y = center.y
		
		self.nutrition = nutrition
		
		self.textLabel?.text = self.nutrition.type.rawValue
		display.setNutrition(self.nutrition)
	}
}