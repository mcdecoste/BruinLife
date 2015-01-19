//
//  NotificationTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/18/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
//	var clock: ClockView?
	var nameLabel = UILabel()
	var timeLabel = UILabel()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		setup()
	}
	
	func setup() {
		nameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		nameLabel.font = .systemFontOfSize(17)
		nameLabel.numberOfLines = 0
		nameLabel.lineBreakMode = .ByWordWrapping
		contentView.addSubview(nameLabel)
		
		timeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		timeLabel.font = .systemFontOfSize(15)
		timeLabel.textColor = UIColor(white: 0.3, alpha: 1)
		timeLabel.textAlignment = .Right
		contentView.addSubview(timeLabel)
		
		// Auto Layout
		contentView.addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
		
		addConstraint("H:|-16-[name]-5-[serving]-16-|", option: .AlignAllCenterY)
		addConstraint("V:|-10-[name]-10-|")
	}
	
	/// Helper method for Auto Layout
	func addConstraint(format: String, option: NSLayoutFormatOptions = .allZeros) {
		contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: option, metrics: nil, views: ["name" : nameLabel, "serving" : timeLabel]))
	}
	
	func setLabels(name: String, time: String = "") {
		nameLabel.text = name
		timeLabel.text = time
	}
}
