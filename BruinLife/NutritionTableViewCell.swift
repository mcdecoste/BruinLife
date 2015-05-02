//
//  NutritionTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/10/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class NutritionTableViewCell: UITableViewCell {
	private var leftText = UILabel()
	private var rightText = UILabel()
	private var leftDisplay = CircleDisplay(frame: CGRect(x: 0, y: 0, width: 36, height: 36))	// 36 or 40
	private var rightDisplay = CircleDisplay(frame: CGRect(x: 0, y: 0, width: 36, height: 36))	// 36 or 40
	private var numberServings: Int = 1
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		finishSetup()
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		finishSetup()
	}
	
	func finishSetup() {
		selectionStyle = .None
		
		leftText.textAlignment = .Left
		rightText.textAlignment = .Left
		
		addSubview(leftText)
		addSubview(rightText)
		addSubview(leftDisplay)
		addSubview(rightDisplay)
	}
	
	func setServingCount(count: Int) {
		numberServings = count == 0 ? 1 : count
		
		leftDisplay.servingCount = numberServings
		rightDisplay.servingCount = numberServings
	}
	
	func setInformation(type: NutrientDisplayType, left: (type: String, information: NutritionListing), right: (type: String, information: NutritionListing)) {
		let textIndent: CGFloat = 15 // to line it up with regular displays
		let rightDisplayIndent: CGFloat = 15 // was 6
		let bigFontSize: CGFloat = 17 // prev 16
		let mediumFontSize: CGFloat = 16 // prev 15
		let smallFontSize: CGFloat = 15 // prev 4
		
		// text
		let halfway = frame.width/2
		let textRight = textIndent + rightDisplayIndent + leftDisplay.frame.width // 36 or 40
		
		let shouldShrink = (type == .oneSub)
		let shrink: CGFloat = shouldShrink ? 0.9 : 1
		let leftTextX = (shouldShrink ? frame.width * (1 - shrink) : 0) + textIndent
		// NOTE: rightTextX doesn't use textIndent because it doesn't need extra spacing
		let rightTextX = halfway + rightDisplayIndent // shrink ? frame.width * 0.025 + halfway + sideIndent :
		var textWidth = (shouldShrink ? frame.width * shrink : halfway) - textRight
		if type == .oneMain { textWidth = frame.width - textRight }
		leftText.frame = CGRect(x: leftTextX, y: 0, width: textWidth, height: frame.height)
		rightText.frame = CGRect(x: rightTextX, y: 0, width: textWidth, height: frame.height)
		
		leftText.text = left.type
		
		// displays
		leftDisplay.frame.origin.x = halfway - leftDisplay.frame.width // - rightDisplayIndent
		leftDisplay.center.y = center.y
		leftDisplay.setNutrition(left.information, servingCount: numberServings)
		
		rightDisplay.frame.origin.x = frame.width - rightDisplay.frame.width - rightDisplayIndent
		rightDisplay.center.y = center.y
		
		var displayCenter = frame.height/2
		
		switch type {
		case .oneMain:
			leftText.font = UIFont.boldSystemFontOfSize(bigFontSize)
			leftDisplay.hidden = true
			rightText.text = ""
			rightDisplay.setNutrition(left.information, servingCount: numberServings)
			rightDisplay.hidden = false
		case .twoMain:
			leftText.font = UIFont.boldSystemFontOfSize(bigFontSize)
			leftDisplay.hidden = false
			rightText.font = UIFont.systemFontOfSize(smallFontSize)
			rightText.text = right.type
			rightDisplay.setNutrition(right.information, servingCount: numberServings)
			rightDisplay.hidden = false
		case .oneSub:
			leftText.font = UIFont.systemFontOfSize(smallFontSize)
			leftDisplay.hidden = true
			rightText.text = ""
			rightDisplay.setNutrition(left.information, servingCount: numberServings)
			rightDisplay.hidden = false
			displayCenter -= 4
		case .doubleMain:
			leftText.font = UIFont.boldSystemFontOfSize(mediumFontSize)
			leftDisplay.hidden = false
			rightText.font = UIFont.boldSystemFontOfSize(mediumFontSize)
			rightText.text = right.type
			rightDisplay.setNutrition(right.information, servingCount: numberServings)
			rightDisplay.hidden = false
		case .doublePlain:
			leftText.font = UIFont.systemFontOfSize(mediumFontSize)
			leftDisplay.hidden = false
			rightText.font = UIFont.systemFontOfSize(mediumFontSize)
			rightText.text = right.type
			rightDisplay.setNutrition(right.information, servingCount: numberServings)
			rightDisplay.hidden = false
		default:
			leftText.text = ""
			leftDisplay.hidden = true
			rightText.text = ""
			rightDisplay.hidden = true
		}
		
		leftText.center.y = displayCenter
		leftDisplay.center.y = displayCenter
		rightText.center.y = displayCenter
		rightDisplay.center.y = displayCenter
	}
}