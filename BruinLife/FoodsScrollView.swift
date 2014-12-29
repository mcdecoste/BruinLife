//
//  FoodsScrollView.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodsScrollView: UIScrollView {
	var displays: Array<FoodDisplay> = []
	var foodVC: FoodTableViewController?
	var lines: Array<UIView> = []
	
	let xIndent: CGFloat = 16.0
	let displayWidth: CGFloat = 160.0
	let numRows: Int = 2
	
	override init(frame: CGRect) {
		foodVC = nil
		super.init(frame: frame)
	}
	
	func setFoods(foods: Array<FoodInfo>, vc: FoodTableViewController, newFrame: CGRect) {
		foodVC = vc
		frame = newFrame
		setFoods(foods)
	}
	
	func setFoods(foods: Array<FoodInfo>) {
		setContentOffset(CGPointZero, animated: false)
		
		// clear out old foods
		for display in displays {
			display.removeFromSuperview()
		}
		for line in lines {
			line.removeFromSuperview()
		}
		
		displays = []
		lines = []
		
		var index = 0
		var maxX: CGFloat = 0.0
		
		for food in foods {
			let theFrame = frameForIndex(index, numRows: numRows)
			var display = FoodDisplay(food: food, index: index, frame: theFrame)
			display.tag = index
			display.addTarget(self, action: "hitFood:", forControlEvents: .TouchUpInside)
			displays.append(display)
			
			addSubview(display)
			
			if index >= numRows {
				let yInset:CGFloat = 20.0
				var width:CGFloat = 1.0 / UIScreen.mainScreen().scale
				var xVal:CGFloat = display.frame.origin.x - xIndent / 2.0
				var yVal:CGFloat = yInset + (CGFloat(index % numRows) * bounds.height / CGFloat(numRows))
				var verticalLine = UIView(frame: CGRect(x: xVal, y: yVal, width: width, height: (frame.height / CGFloat(numRows)) - 2.0 * yInset))
				verticalLine.backgroundColor = .blackColor()
				lines.append(verticalLine)
				addSubview(lines.last!)
			}
			
			index++
			maxX = theFrame.maxX + xIndent
		}
		
		for lineNum in 1...(numRows - 1) {
			var height:CGFloat = 1.0 / UIScreen.mainScreen().scale
			var yVal:CGFloat = CGFloat(lineNum) * frame.height / CGFloat(numRows)
			var horizontalLine = UIView(frame: CGRect(x: xIndent, y: yVal, width: contentSize.width - 2.0 * xIndent, height: height))
			horizontalLine.backgroundColor = .blackColor()
			addSubview(horizontalLine)
			lines.append(horizontalLine)
		}
		
		contentSize = CGSize(width: maxX, height: frame.height)
		if contentSize.width > frame.width {
			scrollEnabled = true
		}
	}
	
	func hitFood(display: FoodDisplay) {
		var foodInfo = display.food
		
		// make a popover
		foodVC?.addFoodPopover(display)
	}
	
	func frameForIndex(index: Int, numRows: Int) -> CGRect {
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
	
	required init(coder aDecoder: NSCoder) {
	    super.init()
	}
}
