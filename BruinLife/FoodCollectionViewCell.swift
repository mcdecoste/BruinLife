//
//  FoodCollectionViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/30/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodCollectionViewCell: UICollectionViewCell {
	var food: MainFoodInfo
	var nameLabel: UILabel
	
	override init(frame: CGRect) {
		food = MainFoodInfo(name: "", type: .Regular)
		nameLabel = UILabel(frame: frame)
		super.init(frame: frame)
		
		// arrange view
		nameLabel.font = .systemFontOfSize(18)
//		nameLabel.minimumScaleFactor = 0.8
		nameLabel.textAlignment = .Center
		nameLabel.numberOfLines = 0 // no, not 2
		nameLabel.lineBreakMode = .ByWordWrapping
//		nameLabel.lineBreakMode = .ByTruncatingTail
		
		addSubview(nameLabel)
//		backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.4)
	}
	
	func set(food: MainFoodInfo, size: CGSize) {
		self.food = food
		var frame = CGRect(origin: CGPointZero, size: size)
		
		// arrange view
		let maxNumLines = 2
		nameLabel.text = food.name
		nameLabel.frame = nameLabel.textRectForBounds(bounds, limitedToNumberOfLines: maxNumLines)
		nameLabel.center = CGPoint(x: frame.origin.x + 0.5 * frame.size.width, y: frame.origin.y + 0.5 * frame.size.height)
	}
	
	required init(coder aDecoder: NSCoder) {
		self.food = MainFoodInfo(name: "CODER", type: .Regular)
		nameLabel = UILabel(frame: CGRectZero)
		super.init()
	}
}
