//
//  FoodCollectionViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/30/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodCollectionViewCell: UICollectionViewCell {
//	var food = MainFoodInfo(name: "", recipe: "000000", type: .Regular)
	var food: FoodBrief = FoodBrief(name: "")
	var nameLabel = UILabel(), typeLabel = UILabel(), extraLabel = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		// establish views
		nameLabel.font = .systemFontOfSize(18) // 43 points for two rows (17 leftover)
		nameLabel.textAlignment = .Center
		nameLabel.numberOfLines = 0
		nameLabel.lineBreakMode = .ByWordWrapping
		nameLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
		nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		typeLabel.font = .systemFontOfSize(12)
		typeLabel.textAlignment = .Left
		typeLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
		typeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		extraLabel.font = .systemFontOfSize(12)
		extraLabel.textAlignment = .Right
		extraLabel.textColor = UIColor(white: 1.0, alpha: 1.0)
		extraLabel.numberOfLines = 0
		extraLabel.lineBreakMode = .ByWordWrapping
		extraLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		contentView.addSubview(nameLabel)
		contentView.addSubview(typeLabel)
		contentView.addSubview(extraLabel)
		
		contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
		
		addConstraint("H:|-(>=4)-[name]-(>=4)-|")
		addConstraint("H:|-4-[type]-(>=4)-[extra]-4-|")
		addConstraint("V:|-0-[name]-0-[type]-(>=0)-|")
		addConstraint("V:|-0-[name]-0-[extra]-(>=0)-|")
	}
	
	func setFood(food: FoodBrief, isHall: Bool) {
		self.food = food
		let subDisplayAlpha: CGFloat = 1.0
		
		// update information
		nameLabel.text = food.name
		
		typeLabel.text = food.type.rawValue
		typeLabel.textColor = food.type.displayColor(subDisplayAlpha)
		
		if let side = food.sideBrief {
			extraLabel.text = (isHall ? "With " : "") + side.name
			extraLabel.textColor = side.type.displayColor(subDisplayAlpha)
		} else {
			extraLabel.text = ""
		}
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	/// Helper method for Auto Layout
	func addConstraint(format: String, option: NSLayoutFormatOptions = .allZeros) {
		let views = ["name" : nameLabel, "type" : typeLabel, "extra" : extraLabel]
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: option, metrics: nil, views: views))
	}
}
