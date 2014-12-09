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
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	/// Preferred method for setting information and date, as this also changes the display
	func changeInfo(info: RestaurantInfo, andDate newDate: NSDate) {
		information = info
		date = newDate
		
		updateDisplay()
	}
	
	func updateDisplay() {
		
	}
}
