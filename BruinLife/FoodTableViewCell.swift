//
//  FoodTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/8/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
	var information: RestaurantInfo?
	var date: NSDate?
	var foodVC: FoodTableViewController?
	var backgroundImageView: UIImageView?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		backgroundImageView = UIImageView(frame: CGRectZero)
		addSubview(backgroundImageView!)
		clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	/// Preferred method for setting information and date, as this also changes the display
	func changeInfo(info: RestaurantInfo, andDate newDate: NSDate) {
		information = info
		date = newDate
		
		var imageIndex = (subviews as NSArray).indexOfObject(backgroundImageView!)
		
		backgroundImageView?.removeFromSuperview()
		
		backgroundImageView = UIImageView(image: information?.darkImage)
		parallaxImageWithScrollPercent(0.0)
		backgroundImageView?.contentMode = .ScaleAspectFill
		
		insertSubview(backgroundImageView!, atIndex: imageIndex)
		
		updateDisplay()
	}
	
	func parallaxImageWithScrollPercent(perc: CGFloat) {
		let parallaxCoeff: CGFloat = 0.5
		
		var percentage: CGFloat = perc
		if perc < 0.0 { percentage = 0.0 }
		if perc > 1.0 { percentage = 1.0 }
		
		let displayHeight:CGFloat = 220.0
		var cellHeight: CGFloat = bounds.height
		
		var startPoint: CGFloat = 0.0 // ((1.0 - parallaxCoeff) / 2.0) * (backgroundImageView?.frame.height)! // (1 - parallaxCoeff) *
		var diff: CGFloat = parallaxCoeff * percentage * (displayHeight - cellHeight)
		
		backgroundImageView?.frame.origin.y = startPoint - diff
	}
	
	func updateDisplay() {}
}
