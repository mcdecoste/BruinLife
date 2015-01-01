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
	var typeLabel: UILabel
	var extraLabel: UILabel
	
	override init(frame: CGRect) {
		food = MainFoodInfo(name: "", type: .Regular)
		nameLabel = UILabel(frame: frame)
		typeLabel = UILabel(frame: frame)
		extraLabel = UILabel(frame: frame)
		
		super.init(frame: frame)
		
		// establish views
		nameLabel.font = .systemFontOfSize(18) // 43 points for two rows (17 leftover)
//		nameLabel.minimumScaleFactor = 0.8
		nameLabel.textAlignment = .Center
		nameLabel.numberOfLines = 0
		nameLabel.lineBreakMode = .ByWordWrapping
		nameLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
//		nameLabel.lineBreakMode = .ByTruncatingTail
		
		typeLabel.font = .systemFontOfSize(12)
		typeLabel.textAlignment = .Left
		typeLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
		
		extraLabel.font = .systemFontOfSize(12)
		extraLabel.textAlignment = .Right
		extraLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
		
		addSubview(nameLabel)
		addSubview(typeLabel)
		addSubview(extraLabel)
//		backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.4)
	}
	
	func setFood(food: MainFoodInfo) {
		self.food = food
		let sideInset: CGFloat = 4.0
		let bottomInset: CGFloat = 2.0
		let subDisplayAlpha: CGFloat = 1.0
		let prefSize = preferredSize()
		
		// arrange view
		nameLabel.text = food.name
		nameLabel.frame.size = nameLabel.textRectForBounds(bounds, limitedToNumberOfLines: 2).size
		nameLabel.center = CGPoint(x: prefSize.width / 2.0, y: 21.5)
		
		typeLabel.text = food.type.rawValue
		typeLabel.frame.size = typeLabel.textRectForBounds(bounds, limitedToNumberOfLines: typeLabel.numberOfLines).size
//		typeLabel.frame.origin = CGPoint(x: sideInset, y: prefSize.height - typeLabel.frame.size.height - bottomInset)
		typeLabel.frame.origin = CGPoint(x: sideInset, y: nameLabel.frame.maxY + 0.0)
		typeLabel.textColor = food.type.displayColor(subDisplayAlpha)
		
		if food.withFood != nil {
			extraLabel.text = "With " + (food.withFood?.name)!
			extraLabel.textColor = (food.withFood?.type.displayColor(subDisplayAlpha))!
		} else {
			extraLabel.text = ""
			extraLabel.textColor = FoodType.Regular.displayColor(subDisplayAlpha)
		}
		extraLabel.frame.size = extraLabel.textRectForBounds(bounds, limitedToNumberOfLines: extraLabel.numberOfLines).size
//		extraLabel.frame.origin = CGPoint(x: prefSize.width - extraLabel.frame.size.width - sideInset, y: prefSize.height - extraLabel.frame.size.height - bottomInset)
		extraLabel.frame.origin = CGPoint(x: prefSize.width - extraLabel.frame.size.width - sideInset, y: nameLabel.frame.maxY + 0.0)
	}
	
	func preferredSize() -> CGSize { return CGSize(width: 240, height: 60) }
	
	required init(coder aDecoder: NSCoder) {
		food = MainFoodInfo(name: "", type: .Regular)
		nameLabel = UILabel(frame: CGRectZero)
		typeLabel = UILabel(frame: CGRectZero)
		extraLabel = UILabel(frame: CGRectZero)
		super.init()
	}
}
