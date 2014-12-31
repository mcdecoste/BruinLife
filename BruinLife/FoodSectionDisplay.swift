//
//  FoodSectionDisplay.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/28/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodSectionDisplay: UIView {
	var scroller: FoodsScrollView?
	
	var title: String
	var displays: Array<FoodDisplay>
	var lines: Array<UIView> = []
	
	/// title sticks to left end
	let titleLeftIndent = 16.0
	/// prevent title from going further right
	let titleRightIndent = 16.0
	
	let xIndent: CGFloat = 16.0
	let displayWidth: CGFloat = 240.0
	let numRows: Int = 3
	
	init(section: SectionInfo, parent: FoodsScrollView) {
		self.scroller = parent
		self.title = section.name
		self.displays = []
		super.init()
		
		layout(section)
	}
	
	override init(frame: CGRect) {
		self.scroller = nil
		self.title = ""
		self.displays = []
		super.init()
	}

	required init(coder aDecoder: NSCoder) {
		self.scroller = nil
		self.title = ""
	    self.displays = []
		super.init()
	}
	
	func layout(section: SectionInfo) {
		// the same stuff from before
		
		var maxX: CGFloat = 0.0
		
		for (index, food) in enumerate(section.foods) {
			var display = FoodDisplay(food: food, bounds: frameForIndex(index).size)
			display.tag = index
//			display.addTarget(scroller!, action: "hitFood:", forControlEvents: .TouchUpInside)
			displays.append(display)
			addSubview(display)
			
			if index >= numRows {
				let yInset: CGFloat = 20.0
				var width: CGFloat = 1.0 / UIScreen.mainScreen().scale
				var xVal: CGFloat = display.frame.origin.x - xIndent / 2.0
				var yVal: CGFloat = yInset + (CGFloat(index % numRows) * bounds.height / CGFloat(numRows))
				var verticalLine = UIView(frame: CGRect(x: xVal, y: yVal, width: width, height: (frame.height / CGFloat(numRows)) - 2.0 * yInset))
				verticalLine.backgroundColor = .blackColor()
				lines.append(verticalLine)
				addSubview(lines.last!)
			}
			
			maxX = display.frame.maxX + xIndent
		}
		
		for lineNum in 1...(numRows - 1) {
			var height:CGFloat = 1.0 / UIScreen.mainScreen().scale
			var yVal:CGFloat = CGFloat(lineNum) * frame.height / CGFloat(numRows)
			var horizontalLine = UIView(frame: CGRect(x: xIndent, y: yVal, width: bounds.width - 2.0 * xIndent, height: height))
			horizontalLine.backgroundColor = .blackColor()
			addSubview(horizontalLine)
			lines.append(horizontalLine)
		}
		
		bounds.size = CGSize(width: maxX, height: frame.height)
		
		// let's add that section label
	}
	
	func frameForIndex(index: Int) -> CGRect {
		let xZeroIndent: CGFloat = xIndent // 16.0
		let yIndent: CGFloat = 8.0 // or 10.0
		let indexLatSpacing: CGFloat = xZeroIndent
		let indexVertSpacing: CGFloat = yIndent
		let displayHeight: CGFloat = (1.0 / CGFloat(numRows)) * (frame.height - (2.0 * yIndent) - (CGFloat(numRows - 1) * indexVertSpacing))
		let xVal = (xZeroIndent + CGFloat(index / numRows) * (indexLatSpacing + displayWidth))
		
		let yMult = ((numRows == 0) ? 0.0 : CGFloat(index % numRows))
		let yVal = (yMult * (indexVertSpacing + displayHeight)) + yIndent
		
		return CGRect(x: xVal, y: yVal, width: displayWidth, height: displayHeight)
	}
}
