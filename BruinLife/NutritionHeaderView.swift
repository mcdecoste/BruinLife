//
//  NutritionHeaderView.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/4/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class NutritionHeaderView: GeneralHeaderView {
	private var sideLabel = UILabel()
	
	var servingsCount: Int = 0 {
		didSet {
			sideLabel.text = plural(servingsCount, "serving", "servings", prefix: "for ", showForZero: false)
			sideLabel.sizeToFit()
			
			setNeedsDisplay()
		}
	}
	
	override func setup() {
		sideLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		sideLabel.font = .italicSystemFontOfSize(12)
		sideLabel.textColor = UIColor(white: 0.3, alpha: 1.0)
		sideLabel.textAlignment = .Right
		
		contentView.addSubview(sideLabel)
		
		// super calls setConstraints, so don't bother with that.
		super.setup()
		
		title = "Nutrition Facts"
	}
	
	override func setConstraints() {
		contentView.removeConstraints(contentView.constraints())
		
		contentView.addConstraint(NSLayoutConstraint(item: mainLabel, attribute: .Bottom, relatedBy: .Equal, toItem: sideLabel, attribute: .Bottom, multiplier: 1, constant: -2))
		
		addConstraint("H:|-[main]-(>=0)-[side]-14-|")
		addConstraint("V:|-[main]-|")
	}
	
	override func addConstraint(format: String, option: NSLayoutFormatOptions = .allZeros) {
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: option, metrics: nil, views: ["main" : mainLabel, "side" : sideLabel]))
	}
}

class GeneralHeaderView: UITableViewHeaderFooterView {
	private var mainLabel = UILabel()
	
	var title: String = "Bruin Tracks" {
		didSet {
			mainLabel.text = title
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	func setup() {
		contentView.backgroundColor = .whiteColor()
		
		mainLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		title = "Bruin Tracks"
		mainLabel.font = .boldSystemFontOfSize(20)
		mainLabel.sizeToFit()
		
		contentView.addSubview(mainLabel)
		
		setConstraints()
	}
	
	func setConstraints() {
		contentView.removeConstraints(contentView.constraints())
		
		addConstraint("H:|-[main]-(>=0)-|")
		addConstraint("V:|-[main]-|")
	}
	
	/// Helper method for Auto Layout
	func addConstraint(format: String, option: NSLayoutFormatOptions = .allZeros) {
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: option, metrics: nil, views: ["main" : mainLabel]))
	}
}
