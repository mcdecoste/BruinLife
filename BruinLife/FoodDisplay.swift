//
//  FoodDisplay.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodDisplay: UIButton { // was UIView
	var food: FoodInfo
	var index = 0
	
	init(food: FoodInfo, index: Int, frame: CGRect) {
		self.food = food
		self.index = index
		
		// establish frame
		super.init(frame: frame)
		
		// arrange view
		let numLines = 3
		var nameLabel = UILabel(frame: bounds)
		nameLabel.font = .systemFontOfSize(20)
		nameLabel.textAlignment = .Center
		nameLabel.text = food.name
		nameLabel.numberOfLines = 0 // no, not 2
		nameLabel.lineBreakMode = .ByWordWrapping
		nameLabel.frame = nameLabel.textRectForBounds(nameLabel.bounds, limitedToNumberOfLines: numLines)
		nameLabel.center = CGPoint(x: bounds.origin.x + 0.5 * bounds.size.width, y: bounds.origin.y + 0.5 * bounds.size.height)
		
		addSubview(nameLabel)
	}
	
	required init(coder aDecoder: NSCoder) {
		self.food = FoodInfo(name: "CODER", type: .Regular)
	    super.init()
	}
}
