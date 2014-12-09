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
		backgroundColor = .lightGrayColor()
		
		// arrange view
		var nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height * 1.0 / 4.0))
		nameLabel.font = .systemFontOfSize(16)
		nameLabel.textAlignment = .Center
		nameLabel.text = food.name
		
		addSubview(nameLabel)
	}
	
	required init(coder aDecoder: NSCoder) {
	    super.init()
	}
}
