//
//  NutritionTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/10/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class NutritionTableViewCell: UITableViewCell {
	var leftText: UILabel = UILabel()
	var rightText: UILabel = UILabel()
//	var leftDisplay: CircleDisplay = CircleDisplay(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
//	var rightDisplay: CircleDisplay = CircleDisplay(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
	var leftDisplay: CircleDisplay = CircleDisplay(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
	var rightDisplay: CircleDisplay = CircleDisplay(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
	
//	var nutrition: NutritionListing = NutritionListing(type: .Cal, measure: "0")
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		finishSetup()
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		finishSetup()
	}
	
	func finishSetup() {
		leftText.textAlignment = .Left
		
		
		rightText.textAlignment = .Left
		
		addSubview(leftText)
		addSubview(rightText)
		addSubview(leftDisplay)
		addSubview(rightDisplay)
	}
	
	func setInformation(information: (type: NutrientDisplayType, left: NutritionListing?, right: NutritionListing?)) {
//		let sideIndent: CGFloat = 8
		let textIndent: CGFloat = 14
		let displayIndent: CGFloat = 6
		let bigFontSize: CGFloat = 17 // prev 16
		let mediumFontSize: CGFloat = 16 // prev 15
		let smallFontSize: CGFloat = 15 // prev 4
		
		// text
		let halfway = frame.width/2
		let textRight = textIndent + displayIndent + 36 // 40
		
		let shouldShrink = (information.type == .oneSub)
		let shrink: CGFloat = shouldShrink ? 0.9 : 1
		let leftTextX = (shouldShrink ? frame.width * (1 - shrink) : 0) + textIndent
		// NOTE: rightTextX doesn't use textIndent because it doesn't need extra spacing
		let rightTextX = halfway + displayIndent // shrink ? frame.width * 0.025 + halfway + sideIndent :
		var textWidth = (shouldShrink ? frame.width * shrink : halfway) - textRight
		if information.type == .oneMain { textWidth = frame.width - textRight }
		leftText.frame = CGRect(x: leftTextX, y: 0, width: textWidth, height: frame.height)
		rightText.frame = CGRect(x: rightTextX, y: 0, width: textWidth, height: frame.height)
		
		leftText.text = information.left?.type.rawValue
		
		// displays
		leftDisplay.frame.origin.x = halfway - leftDisplay.frame.width - displayIndent
		leftDisplay.center.y = center.y
		leftDisplay.setNutrition((information.left)!)
		
		rightDisplay.frame.origin.x = frame.width - rightDisplay.frame.width - displayIndent
		rightDisplay.center.y = center.y
		
		switch information.type {
		case .oneMain:
			leftText.font = UIFont.boldSystemFontOfSize(bigFontSize)
			leftDisplay.hidden = true
			rightText.text = ""
			rightDisplay.setNutrition((information.left)!)
			rightDisplay.hidden = false
		case .twoMain:
			leftText.font = UIFont.boldSystemFontOfSize(bigFontSize)
			leftDisplay.hidden = false
			rightText.font = UIFont.systemFontOfSize(smallFontSize)
			rightText.text = information.right?.type.rawValue
			rightDisplay.setNutrition((information.right)!)
			rightDisplay.hidden = false
		case .oneSub:
			leftText.font = UIFont.systemFontOfSize(bigFontSize)
			leftDisplay.hidden = true
			rightText.text = ""
			rightDisplay.setNutrition((information.left)!)
			rightDisplay.hidden = false
		case .doubleMain:
			leftText.font = UIFont.boldSystemFontOfSize(mediumFontSize)
			leftDisplay.hidden = false
			rightText.font = UIFont.boldSystemFontOfSize(mediumFontSize)
			rightText.text = information.right?.type.rawValue
			rightDisplay.setNutrition((information.right)!)
			rightDisplay.hidden = false
		default:
			leftText.text = ""
			leftDisplay.hidden = true
			rightText.text = ""
			rightDisplay.hidden = true
		}
		
		leftDisplay.center.y = frame.height / 2
		rightDisplay.center.y = frame.height / 2
	}
}