//
//  FoodDisplay.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodDisplay: UIButton { // was UIView
	var food = FoodInfo(name: "DEFAULT", image: nil)
	var index = 0
	
	init(info: FoodInfo, ind: Int, frame: CGRect) {
		food = info
		index = ind
		
		// establish frame
		super.init(frame: frame)
//		backgroundColor = UIColor(white: 0.75, alpha: 0.25)
		
		// arrange view
		let numLines = 3
//		var nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
		var nameLabel = UILabel(frame: bounds)
		nameLabel.font = .systemFontOfSize(20)
		nameLabel.textAlignment = .Center
		nameLabel.text = food.name
		nameLabel.numberOfLines = 0 // no, not 2
		nameLabel.lineBreakMode = .ByWordWrapping
		nameLabel.frame = nameLabel.textRectForBounds(nameLabel.bounds, limitedToNumberOfLines: numLines)
//		nameLabel.center = CGPoint(x: frame.origin.x + 0.5 * frame.size.width, y: frame.origin.y + 0.5 * frame.size.height)
		
		nameLabel.center = CGPoint(x: bounds.origin.x + 0.5 * bounds.size.width, y: bounds.origin.y + 0.5 * bounds.size.height)
		
//		println("\(food.name): \(nameLabel.frame)")
//		println("\(nameLabel.center) =?= \(center)")
		
		addSubview(nameLabel)
	}
	
	required init(coder aDecoder: NSCoder) {
	    super.init()
	}
}
