//
//  FoodCollectionViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/30/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodCollectionViewCell: UICollectionViewCell {
	var food: FoodBrief = FoodBrief() {
		didSet {
			nameLabel.text = food.name
			
			typeLabel.text = food.type.rawValue
			typeLabel.textColor = food.type.displayColor
			
			extraLabel.text = food.sideBrief?.name
			extraLabel.textColor = food.sideBrief?.type.displayColor
		}
	}
	private var nameLabel = UILabel(), typeLabel = UILabel(), extraLabel = UILabel()
	private let largeText = UIFont.systemFontOfSize(18), smallText = UIFont.systemFontOfSize(12) // large: 43 points for two rows (17 leftover)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		// establish views
		nameLabel.font = largeText
		nameLabel.textAlignment = .Center
		nameLabel.numberOfLines = 0
		nameLabel.lineBreakMode = .ByWordWrapping
		nameLabel.textColor = .whiteColor()
		nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		typeLabel.font = smallText
		typeLabel.textColor = .whiteColor()
		typeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		extraLabel.font = smallText
		extraLabel.textAlignment = .Right
		extraLabel.textColor = .whiteColor()
		extraLabel.numberOfLines = 0
		extraLabel.lineBreakMode = .ByWordWrapping
		extraLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		contentView.addSubview(nameLabel)
		contentView.addSubview(typeLabel)
		contentView.addSubview(extraLabel)
		
		contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
		contentView.addConstraint(NSLayoutConstraint(item: extraLabel, attribute: .Bottom, relatedBy: .Equal, toItem: typeLabel, attribute: .Bottom, multiplier: 1, constant: 0))
		
		addConstraint("H:|-(>=2)-[name]-(>=2)-|")
		addConstraint("H:|-2-[type]-(>=4)-[extra]-2-|")
		addConstraint("V:|-0-[name]-(>=0)-[type]-2-|")
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	/// Helper method for Auto Layout
	private func addConstraint(format: String, option: NSLayoutFormatOptions = .allZeros) {
		let views = ["name" : nameLabel, "type" : typeLabel, "extra" : extraLabel]
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: option, metrics: nil, views: views))
	}
}
