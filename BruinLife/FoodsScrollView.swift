//
//  FoodsScrollView.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 11/26/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodsScrollView: UIScrollView {
	var sections: Array<FoodSectionDisplay> = []
	var foodVC: FoodTableViewController?
	
	override init(frame: CGRect) {
		foodVC = nil
		super.init(frame: frame)
	}
	
	func setSections(sections: Array<SectionInfo>, vc: FoodTableViewController, frame: CGRect) {
		foodVC = vc
		self.frame = frame
		setSections(sections)
	}
	
	func setSections(sections: Array<SectionInfo>) {
		setContentOffset(CGPointZero, animated: false)
		
		// clear out old foods
		for display in self.sections { display.removeFromSuperview() }
		self.sections = []
		
		var index = 0
		var previousMaxX: CGFloat = 0.0
		
		for section in sections {
			var nextSection = FoodSectionDisplay(section: section, parent: self)
//			nextSection.frame = CGRect(origin: CGSize(x: previousMaxX, y: 0.0), size: nextSection.bounds.size)
			nextSection.frame.origin.x = previousMaxX
			self.sections.append(nextSection)
		}
	}
	
	func hitFood(display: FoodDisplay) {
		var foodInfo = display.food
		
		// make a popover
		foodVC?.addFoodPopover(display)
	}
	
	required init(coder aDecoder: NSCoder) {
	    super.init()
	}
}
