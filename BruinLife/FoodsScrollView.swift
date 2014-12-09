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
	
	let xIndent: CGFloat = 16.0
	let displayWidth: CGFloat = 160.0
	
	var foodVC: FoodTableViewController?
	
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
		
		for display in displays {
			display.removeFromSuperview()
		}
		
		displays = []
		
		var index = 0
		var maxX: CGFloat = 0.0
		for food in foods {
			let theFrame = frameForIndex(index, numRows: 3)
			var display = FoodDisplay(info: food, ind: index, frame: theFrame)
			display.tag = index
			display.addTarget(self, action: "hitFood:", forControlEvents: .TouchUpInside)
			displays.append(display)
			addSubview(display)
			index++
			maxX = theFrame.maxX + xIndent
		}
		
		contentSize = CGSize(width: maxX, height: frame.height)
		if contentSize.width > frame.width {
			scrollEnabled = true
		}
	}
	
	func hitFood(display: FoodDisplay) {
		var foodInfo = display.food
		
		// make a popover
		foodVC?.showFoodPopover(foodInfo)
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
